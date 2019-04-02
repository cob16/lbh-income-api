require 'rails_helper'

describe Hackney::Notification::RequestPrecompiledLetterState do
  let!(:unique_reference) { SecureRandom.uuid }
  let(:notification_gateway) { Hackney::Income::StubNotificationsGateway.new }
  let(:add_action_diary_usecase) { double(Hackney::Tenancy::AddActionDiaryEntry) }

  let(:notification_response) do
    described_class.new(
      notification_gateway: notification_gateway,
      add_action_diary_usecase: add_action_diary_usecase
    )
  end

  let(:document) do
    Hackney::Cloud::Document.create(
      filename: 'test_file.txt',
      uuid: unique_reference,
      status: 'uploaded'
    )
  end

  describe '#execute' do
    let(:response) { notification_response.execute(unique_reference: document.uuid) }

    it 'gets request' do
      expect(response[:status]).to eq "received"
    end

    it 'updates document state' do
      doc = Hackney::Cloud::Document.find(document.id)
      expect{ response }.to change{ doc.reload.status }.from('uploaded').to('received')
    end
  end
end
