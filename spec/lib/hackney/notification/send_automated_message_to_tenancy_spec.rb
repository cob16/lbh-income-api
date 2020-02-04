require 'rails_helper'

describe Hackney::Notification::SendAutomatedMessageToTenancy do
  subject do
    described_class.new(
      automated_sms_usecase: sms_mock,
      automated_email_usecase: email_mock,
      contacts_gateway: contacts_gateway_mock
    )
  end

  let(:sms_mock) { double(Hackney::Notification::SendAutomatedSms) }
  let(:email_mock) { double(Hackney::Notification::SendAutomatedEmail) }
  let(:contacts_gateway_mock) { double(Hackney::Tenancy::Gateway::ContactsGateway) }
  let(:sms_template_id) { SecureRandom.uuid }
  let(:email_template_id) { SecureRandom.uuid }
  let(:batch_id) { SecureRandom.uuid }
  let(:variables) { { something: 'here', and: 'there' } }

  context 'when sending an automated message' do
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

    it 'looks up contacts by tenancy_ref using the contacts gateway' do
      expect(contacts_gateway_mock).to receive(:get_responsible_contacts)
        .with(tenancy_ref: tenancy_ref)
        .and_return([])

      subject.execute(
        tenancy_ref: tenancy_ref,
        sms_template_id: nil,
        email_template_id: nil,
        batch_id: nil,
        variables: {}
      )
    end

    context 'when there are no duplicate phone numbers' do
      let(:phone_numbers) do
        [
          Faker::PhoneNumber.phone_number,
          Faker::PhoneNumber.phone_number,
          Faker::PhoneNumber.phone_number
        ]
      end

      let(:contacts) do
        [
          Hackney::Income::Domain::Contact.new.tap do |c|
            c.phone_numbers = [phone_numbers[0], phone_numbers[1]]
            c.email = email
          end,
          Hackney::Income::Domain::Contact.new.tap do |c|
            c.phone_numbers = [phone_numbers[2]]
            c.email = email
          end,
          Hackney::Income::Domain::Contact.new # empty contact
        ]
      end

      it 'tries to sms all available numbers' do
        allow(contacts_gateway_mock).to receive(:get_responsible_contacts).and_return(contacts)
        allow(email_mock).to receive(:execute)

        phone_numbers.each do |number|
          expect(sms_mock).to receive(:execute).with(
            phone_number: number,
            template_id: sms_template_id,
            tenancy_ref: '000001/FAKE',
            reference: batch_id,
            variables: variables
          ).once
        end

        subject.execute(
          tenancy_ref: tenancy_ref,
          sms_template_id: sms_template_id,
          email_template_id: email_template_id,
          batch_id: batch_id,
          variables: variables
        )
      end
    end

    context 'when there are duplicate phone numbers' do
      it 'does not send duplicate sms' do
        allow(contacts_gateway_mock).to receive(:get_responsible_contacts).and_return(contacts)
        allow(email_mock).to receive(:execute)

        expect(sms_mock).to receive(:execute).with(
          phone_number: phone_number,
          template_id: sms_template_id,
          tenancy_ref: '000001/FAKE',
          reference: batch_id,
          variables: variables
        ).once

        subject.execute(
          tenancy_ref: tenancy_ref,
          sms_template_id: sms_template_id,
          email_template_id: email_template_id,
          batch_id: batch_id,
          variables: variables
        )
      end
    end

    context 'when there are no duplicate email addresses' do
      let(:emails) do
        [
          Faker::Internet.safe_email,
          Faker::Internet.safe_email
        ]
      end

      let(:contacts) do
        [
          Hackney::Income::Domain::Contact.new.tap do |c|
            c.phone_numbers = [phone_number, phone_number]
            c.email = emails[0]
          end,
          Hackney::Income::Domain::Contact.new.tap do |c|
            c.phone_numbers = [phone_number]
            c.email = emails[1]
          end,
          Hackney::Income::Domain::Contact.new # empty contact
        ]
      end

      it 'tries to email all contacts with email' do
        allow(contacts_gateway_mock).to receive(:get_responsible_contacts).and_return(contacts)
        allow(sms_mock).to receive(:execute)

        emails.each do |email|
          expect(email_mock).to receive(:execute).with(
            tenancy_ref: tenancy_ref,
            recipient: email,
            template_id: email_template_id,
            reference: batch_id,
            variables: variables
          ).once
        end

        subject.execute(
          tenancy_ref: tenancy_ref,
          sms_template_id: sms_template_id,
          email_template_id: email_template_id,
          batch_id: batch_id,
          variables: variables
        )
      end
    end

    context 'when there are duplicate email addresses' do
      it 'does not send duplicate email' do
        allow(contacts_gateway_mock).to receive(:get_responsible_contacts).and_return(contacts)
        allow(sms_mock).to receive(:execute)

        expect(email_mock).to receive(:execute).with(
          tenancy_ref: tenancy_ref,
          recipient: email,
          template_id: email_template_id,
          reference: batch_id,
          variables: variables
        ).once

        subject.execute(
          tenancy_ref: tenancy_ref,
          sms_template_id: sms_template_id,
          email_template_id: email_template_id,
          batch_id: batch_id,
          variables: variables
        )
      end
    end
  end
end
