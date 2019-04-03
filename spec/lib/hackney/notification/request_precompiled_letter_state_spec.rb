require 'rails_helper'

describe Hackney::Notification::RequestPrecompiledLetterState do
  let!(:message_id) { SecureRandom.uuid }
  let(:notification_gateway) { Hackney::Income::StubNotificationsGateway.new }
  let(:add_action_diary_usecase) { double(Hackney::Tenancy::AddActionDiaryEntry) }
  let(:document_store) { Hackney::Cloud::Document }
  let(:notification_response) do
    described_class.new(
      notification_gateway: notification_gateway,
      add_action_diary_usecase: add_action_diary_usecase,
      document_store: document_store
    )
  end

  let(:document) do
    document_store.create(
      filename: 'test_file.txt',
      ext_message_id: message_id,
      status: 'uploaded'
    )
  end

  describe '#execute' do
    let(:response) { notification_response.execute(message_id: document.uuid) }

    it 'gets request' do
      expect(response[:status]).to eq 'received'
    end

    it 'updates document state' do
      doc = Hackney::Cloud::Document.find(document.id)
      expect { response }.to change { doc.reload.status }.from('uploaded').to('received')
    end
  end
end
