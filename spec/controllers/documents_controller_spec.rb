require 'rails_helper'

describe DocumentsController do
  describe '#down' do
    let(:download_use_case) { instance_double(Hackney::Letter::DownloadUseCase, execute: { content: 'Hello Hackney' }) }
    let(:letter_instance) { double(download: download_use_case) }

    context 'when the document is present' do
      before do
        allow(Hackney::Letter::UseCaseFactory)
          .to receive(:new)
          .and_return(letter_instance)
      end

      let(:id) { Random.rand(100).to_s }

      it 'download the document' do
        expect(download_use_case).to receive(:execute).with(id: id)
        expect_any_instance_of(described_class).to receive(:send_data).with('Hello Hackney', filename: 'letter.pdf')

        get :download, params: { id: id }
      end
    end
  end
end
