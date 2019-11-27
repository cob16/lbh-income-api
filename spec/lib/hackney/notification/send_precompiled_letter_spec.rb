require 'rails_helper'

describe Hackney::Notification::SendPrecompiledLetter do
  let(:notification_gateway) { Hackney::Income::StubNotificationsGateway.new }
  let(:send_precompiled_letter) do
    described_class.new(
      notification_gateway: notification_gateway
    )
  end

  let(:test_file) { File.open('spec/test_files/test_pdf.pdf', 'rb') }
  let(:unique_reference) { SecureRandom.uuid }

  context 'when sending a letter' do
    let(:subject) do
      send_precompiled_letter.execute(
        unique_reference: unique_reference,
        letter_pdf: test_file
      )
    end

    it { expect(subject).to be_a Hackney::Notification::Domain::NotificationReceipt }
    it { expect(subject.body).to include(unique_reference) }
  end
end
