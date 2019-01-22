require 'rails_helper'

describe Hackney::Income::Jobs::SendGreenInArrearsMsgJob do
  subject { described_class }

  let(:mock_automated_message) { double(Hackney::Income::SendAutomatedMessageToTenancy) }
  let(:tenancy_ref) { Faker::Internet.slug }
  let(:balance) { Faker::Number.decimal(2) }

  before do
    stub_const('Hackney::Income::GovNotifyGateway', Hackney::Income::DummyGovNotifyGateway)
    stub_const('Hackney::Income::SendAutomatedMessageToTenancy', mock_automated_message)
    allow(mock_automated_message).to receive(:new).and_return(mock_automated_message)
  end

  it 'calls usecase with correct args' do
    expect(mock_automated_message).to receive(:execute).with(
      hash_including(
        tenancy_ref: tenancy_ref,
        sms_template_id: Rails.configuration.x.green_in_arrears.sms_template_id,
        email_template_id: Rails.configuration.x.green_in_arrears.email_template_id,
        variables: { balance: balance }
      )
    ).once
    subject.perform_now(tenancy_ref: tenancy_ref, balance: balance)
  end

  it 'is able to be scheduled' do
    expect do
      subject.set(wait_until: Time.now + 5.minutes).perform_later
    end.not_to raise_error
  end
end
