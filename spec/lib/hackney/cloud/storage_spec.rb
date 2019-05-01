require 'rails_helper'

describe Hackney::Cloud::Storage, type: :model do
  let(:cloud_adapter_fake) { double(:upload) }
  let(:storage) { described_class.new(cloud_adapter_fake, Hackney::Cloud::Document) }

  describe '#upload' do
    it 'saves the file and return the ID' do
      expect(cloud_adapter_fake).to receive(:upload).with(bucket_name: 'my-bucket', content: 'my-file', filename: 'new-filename')

      storage.upload('my-bucket', 'my-file', 'new-filename')
    end
  end

  describe 'retrieve all document' do
    it 'retrieves all documents' do
      expect(Hackney::Cloud::Document).to receive(:all)

      storage.all_documents
    end

    context 'when payment_ref param is used' do
      let(:payment_ref) { Faker::Number.number(10) }

      before do
        Hackney::Cloud::Document.create(filename: '-', uuid: SecureRandom.uuid, extension: '-', mime_type: '-',
                                        metadata: { payment_ref: payment_ref }.to_json)
      end

      context 'when payment_ref exists' do
        it 'finds the correct documents' do
          expect(storage.all_documents(payment_ref: payment_ref).count).to eq(1)
        end
      end

      context 'when payment_ref does not exist' do
        it 'returns 0 entries' do
          expect(storage.all_documents(payment_ref: 'NON-EXISTENT-PAYMENT-REF').count).to eq(0)
        end
      end
    end
  end

  describe '#save' do
    context 'when the file exists' do
      let(:file) { File.open('spec/test_files/test_pdf.pdf', 'rb') }
      let(:filename) { File.basename(file) }
      let(:uuid) { SecureRandom.uuid }
      let(:metadata) { { bunnies: true } }
      let(:letter_html) { "<h1>#{Faker::RickAndMorty.quote}</h1>" }

      it 'creates a new entry' do
        expect { storage.save(letter_html: letter_html, uuid: uuid, filename: filename, metadata: metadata) }.to(change(Hackney::Cloud::Document, :count).by(1))

        doc = Hackney::Cloud::Document.last

        expect(doc.uuid).not_to be_empty
        expect(doc.extension).to eq File.extname(file)
        expect(doc.filename).to eq File.basename(file)
        expect(doc.mime_type).to eq('application/pdf')
        expect(doc.status).to eq 'uploading'
        expect(doc.metadata).to eq metadata.to_json
      end

      it 'enqueues the job to save the file to the cloud' do
        expect {
          storage.save(letter_html: letter_html, uuid: uuid, filename: filename, metadata: metadata)
        }.to(have_enqueued_job(Hackney::Income::Jobs::SaveAndSendLetterJob).with { |params|
          file.rewind
          expect(params[:bucket_name]).to eq 'hackney-docs-test'
          expect(params[:filename]).to eq File.basename(file)
          expect(params[:document_id]).not_to be_nil
          expect(params[:letter_html]).to eq letter_html
        })
      end
    end

    describe '#read_document' do
      let(:document) { create(:document) }

      context 'when the file exists' do
        it 'retrieves the content' do
          uuid = document.uuid

          expect(cloud_adapter_fake).to receive(:download)
            .with(bucket_name: 'hackney-docs-test', filename: "#{uuid}.pdf")
            .and_return(double(:tempfile, path: '/tmp/tempfile'))

          expect(storage.read_document(document.id)[:filepath]).to eq('/tmp/tempfile')
        end
      end
    end
  end
end
