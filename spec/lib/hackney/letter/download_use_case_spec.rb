require 'rails_helper'

describe Hackney::Letter::DownloadUseCase do
  describe '#execute' do
    let(:filename) { './spec/lib/hackney/cloud/adapter/upload_test.txt' }
    let(:file_content) { File.read(filename) }

    let!(:cloud_storage_fake) { Hackney::Cloud::StorageFake.new(:adapter, Hackney::Cloud::Document) }

    it '#save' do
      new_document = cloud_storage_fake.save(filename)

      response = described_class.new(cloud_storage_fake).execute(uuid: new_document[:uuid])

      expect(response).to eq(file_content)
    end
  end
end
