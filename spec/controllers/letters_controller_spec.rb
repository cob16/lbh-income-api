require 'rails_helper'

describe LettersController do
  describe '#show' do
    let(:download_use_case) { instance_double(Hackney::Letter::DownloadUseCase, execute: { content: 'Hello Hackney' }) }
    let(:letter_instance) { double(download: download_use_case) }

    context 'when the document uuid is present' do
      before do
        allow(Hackney::Letter::UseCaseFactory)
          .to receive(:new)
          .and_return(letter_instance)
      end

      let(:uuid) { SecureRandom.uuid }

      it 'download the document' do
        expect(download_use_case).to receive(:execute).with(uuid: uuid)
        expect_any_instance_of(described_class).to receive(:send_data).with('Hello Hackney', filename: 'letter.pdf')

        get :download, params: { uuid: uuid }
      end
    end
  end
end
