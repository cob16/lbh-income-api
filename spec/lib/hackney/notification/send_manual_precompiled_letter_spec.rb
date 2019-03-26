require 'rails_helper'

describe Hackney::Notification::SendManualPrecompiledLetter do
  let(:notification_gateway) { Hackney::Income::StubNotificationsGateway.new }
  let(:add_action_diary_usecase) { double(Hackney::Tenancy::AddActionDiaryEntry) }
  let(:send_precompiled_letter) do
    described_class.new(
      notification_gateway: notification_gateway,
      add_action_diary_usecase: add_action_diary_usecase
    )
  end

  let(:test_file) { File.open('spec/test_files/test_pdf.pdf', 'rb') }
  let(:unique_reference) { SecureRandom.uuid }

  context 'when sending an letters manually' do
    subject do
      send_precompiled_letter.execute(
        unique_reference: unique_reference,
        letter_pdf: test_file
      )
    end

    it { expect(subject).to be_a Hackney::Notification::Domain::NotificationReceipt }
    it { expect(subject.body).to include(unique_reference) }
  end
end
