require 'rails_helper'

describe Hackney::Income::SendAutomatedMessageToTenancy do
  let(:sms_mock) { double(Hackney::Income::SendAutomatedSms) }
  let(:email_mock) { double(Hackney::Income::SendAutomatedEmail) }
  let(:contacts_gateway_mock) { double(Hackney::Tenancy::Gateway::ContactsGateway) }

  let(:sms_template_id) { SecureRandom.uuid }
  let(:email_template_id) { SecureRandom.uuid }
  let(:batch_id) { SecureRandom.uuid }
  let(:variables) { {somthing: 'here', and: 'there'} }

  subject do
    described_class.new(
      automated_sms_usecase: sms_mock,
      automated_email_usecase: email_mock,
      contacts_gateway: contacts_gateway_mock
    )
  end

  context 'when sending a automated message' do
    let(:tenancy_ref) { example_tenancy[:ref] }

    let(:phone_number) { Faker::PhoneNumber.phone_number }
    let(:email) { Faker::Internet.safe_email }
    let(:contacts) do
      [
        Hackney::Income::Domain::Contact.new.tap do |c|
          c.phone_numbers = [phone_number, phone_number]
          c.email = email
        end,
        Hackney::Income::Domain::Contact.new.tap do |c|
          c.phone_numbers = [phone_number]
          c.email = email
        end,
        Hackney::Income::Domain::Contact.new # empty contact
      ]
    end

    it 'should look up contacts by ten_ref using the contacts gateway' do
      expect(contacts_gateway_mock).to receive(:get_responsible_contacts)
        .with(tenancy_ref: tenancy_ref)
        .and_return([])

      subject.execute(tenancy_ref: tenancy_ref, sms_template_id: nil, email_template_id: nil, batch_id: nil, variables: {})
    end

    it 'should try to sms the list of available numbers' do
      allow(contacts_gateway_mock).to receive(:get_responsible_contacts).and_return(contacts)
      allow(email_mock).to receive(:execute)

      expect(sms_mock).to receive(:execute).with(
        phone_number: phone_number,
        template_id: sms_template_id,
        reference: batch_id,
        variables: variables
      ).exactly(3).times
      subject.execute(tenancy_ref: tenancy_ref, sms_template_id: sms_template_id, email_template_id: email_template_id, batch_id: batch_id, variables: variables)
    end

    it 'should try to email all contacts with email' do
      allow(contacts_gateway_mock).to receive(:get_responsible_contacts).and_return(contacts)
      allow(sms_mock).to receive(:execute)

      expect(email_mock).to receive(:execute).with(
        recipient: email,
        template_id: email_template_id,
        reference: batch_id,
        variables: variables
      ).exactly(2).times
      subject.execute(tenancy_ref: tenancy_ref, sms_template_id: sms_template_id, email_template_id: email_template_id, batch_id: batch_id, variables: variables)
    end
  end
end
