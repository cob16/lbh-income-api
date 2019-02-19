require 'rails_helper'
require 'pry'
describe Hackney::Notification::SendPrecompiledLetter do
  let(:notification_gateway) { Hackney::Income::StubNotificationsGateway.new }
  let(:add_action_diary_usecase) { double(Hackney::Tenancy::AddActionDiaryEntry) }
  let(:send_precompiled_letter) do
    described_class.new(
      notification_gateway: notification_gateway,
      add_action_diary_usecase: add_action_diary_usecase
    )
  end

  let(:test_file_path) { 'spec/test_files/test_pdf.pdf' }

  # before do
  #   allow(add_action_diary_usecase).to receive(:execute)
  # end

  context 'when sending an letters manually' do
    subject do
      # def execute(user_id: nil, tenancy_ref: nil, unique_reference:, letter_pdf_location:)

      send_precompiled_letter.execute(
        # user_id: user_id,
        # tenancy_ref: tenancy.tenancy_ref,
        unique_reference: SecureRandom.uuid,
        letter_pdf_location: test_file_path
      )
      # notification_gateway.last_text_message
    end

    it { expect(subject) }
    it { binding.pry }
  end
end
