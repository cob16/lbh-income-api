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

  let(:test_file_path) { 'spec/test_files/test_pdf.pdf' }
  let(:unique_reference) { SecureRandom.uuid }

  context 'when sending an letters manually' do
    subject do
      send_precompiled_letter.execute(
        # user_id: user_id,
        # payment_ref: payment_ref,
        unique_reference: unique_reference,
        letter_pdf_location: test_file_path
      )
    end

    it { expect(subject).to be_a Hackney::Income::Domain::NotificationReceipt }
    it { expect(subject.body).to include(unique_reference) }
  end
end
