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
  describe '#save' do
    context 'when the file exists' do
      # let(:filename) { './spec/lib/hackney/cloud/adapter/upload_test.txt' }

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
      let(:id) { 123 }

      context 'when the file exists' do
        it 'retrieves the content' do
          stub_const('Hackney::Cloud::Document', CloudDocumentFake)

          uuid = CloudDocumentFake.find_by(id: id).uuid

          expect(cloud_adapter_fake).to receive(:download)
            .with('hackney-docs-test', "#{uuid}.pdf")
            .and_return('Hello Hackney')

          expect(storage.read_document(uuid)).to eq(content: 'Hello Hackney')
        end
      end

      context 'when the file does NOT exists' do
        let(:non_existent_uuid) { 'non_existent_uuid' }

        it 'raises an exception' do
          expect {
            storage.read_document(non_existent_uuid)
          }.to raise_exception('File does not exist!')
        end
      end
    end
  end
end

class CloudDocumentFake
  @uuid = SecureRandom.uuid

  def self.find_by(id:)
    Struct.new(:uuid, :extension)
          .new(@uuid, '.pdf')
  end
end
