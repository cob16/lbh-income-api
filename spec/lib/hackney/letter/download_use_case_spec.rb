require 'rails_helper'

describe Hackney::Letter::DownloadUseCase do
  describe '#execute' do
    subject(:download_use_case) { described_class.new(cloud_storage_double) }

    let(:cloud_storage_double) { double(:read_document) }

    let(:id) { Random.rand(100) }

    it '#save' do
      expect(cloud_storage_double).to receive(:read_document).with(id)

      download_use_case.execute(id: id)
    end
  end
end
