require 'rails_helper'

describe Hackney::Cloud::Storage, type: :model do
  let(:storage) { described_class.new(cloud_adapter_fake, Hackney::Cloud::Document) }
  let(:cloud_adapter_fake) { Rails.configuration.cloud_adapter }

  describe '#upload' do
    it 'saves the file and return the ID' do
      expect(cloud_adapter_fake).to receive(:upload).with(bucket_name: 'my-bucket',
                                                          filename: 'my-file',
                                                          new_filename: 'new-filename')

      storage.upload('my-bucket', 'my-file', 'new-filename')
    end
  end

  describe '#save' do
    context 'when the file exists' do
      let(:filename) { './spec/lib/hackney/cloud/adapter/upload_test.txt' }

      it 'creates a new entry' do
        expect { storage.save(filename) }.to(change(Hackney::Cloud::Document, :count).by(1))

        doc = Hackney::Cloud::Document.last

        expect(doc.uuid).not_to be_empty
        expect(doc.extension).to eq('.txt')
        expect(doc.filename).to include('.txt')
        expect(doc.mime_type).to eq('text/plain')
        expect(doc.status).to eq 'uploading'
      end

      it 'enqueues the job to save the file to the cloud' do
        expect {
          storage.save(filename)
        }.to(have_enqueued_job.with { |params|
          expect(params[:bucket_name]).to eq 'hackney-docs-test'
          expect(params[:filename]).to eq './spec/lib/hackney/cloud/adapter/upload_test.txt'
          expect(params[:model_document]).to eq 'Hackney::Cloud::Document'
          expect(params[:uuid]).not_to be_nil
          expect(params[:new_filename]).to include('.txt')
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

    context 'when the file DOES NOT exist' do
      let(:filename) { 'non-existent-file.txt' }

      it 'raises an exception AND does not create a new entry in Cloud::Document' do
        expect { storage.save(filename) }.to raise_exception('No such file: non-existent-file.txt')
      end

      it 'does not create a new entry in Cloud::Document' do
        expect {
          begin
            storage.save(filename)
          rescue StandardError
            nil
          end
        }.not_to change(Hackney::Cloud::Document, :count)
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
