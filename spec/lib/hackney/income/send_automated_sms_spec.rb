require 'rails_helper'

describe Hackney::Income::SendAutomatedSms do
  let(:tenancy) { create_tenancy_model }
  let(:notification_gateway) { double(Hackney::Income::GovNotifyGateway) }

  before do
    tenancy.save
  end

  let(:send_sms) do
    described_class.new(
      notification_gateway: notification_gateway
    )
  end

  context 'when sending an SMS automatically' do
    let(:template_id) { Faker::Superhero.power }
    let(:phone_number) { '020 8356 3000' }
    let(:e164_phone_number) { '+442083563000' }
    let(:reference) { Faker::Superhero.prefix }
    let(:first_name) { Faker::Superhero.name }

    subject do
      send_sms.execute(
        template_id: template_id,
        phone_number: phone_number,
        reference: reference,
        variables: { 'first name': first_name }
      )
    end

    it 'should pass vars to the gateway' do
      expect(notification_gateway).to receive(:send_text_message)
        .with(
          variables: {
            'first name': first_name
          },
          phone_number: e164_phone_number,
          template_id: template_id,
          reference: reference
        )
      subject
    end

    it 'should validate and format a full e164 phone number, assuming local numbers are from uk' do
      expect(notification_gateway)
        .to receive(:send_text_message)
        .with(include(phone_number: e164_phone_number))

      subject
    end

    context 'and when number is invalid' do
      let(:phone_number) { SecureRandom.uuid }

      it 'should not call gateway and return false' do
        expect(notification_gateway).not_to receive(:send_text_message)
        subject
      end
    end
  end
end
