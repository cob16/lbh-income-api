require 'rails_helper'

describe Hackney::Income::SendAutomatedSms do
  let(:tenancy) { create_tenancy_model }
  let(:notification_gateway) { Hackney::Income::StubNotificationsGateway.new }

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
    let(:phone_number) { Faker::Number.leading_zero_number(11) }
    let(:reference) { Faker::Superhero.prefix }
    let(:first_name) { Faker::Superhero.name }

    subject do
      send_sms.execute(
        template_id: template_id,
        phone_number: phone_number,
        reference: reference,
        variables: { 'first name' => first_name }
      )
      notification_gateway.last_text_message
    end

    it 'should map the tenancy to a set of variables' do
      expect(subject).to include(
        variables: include(
          'first name' => first_name
        )
      )
    end

    it 'should pass through the phone number' do
      expect(subject).to include(
        phone_number: phone_number
      )
    end

    it 'should pass through the template id' do
      expect(subject).to include(
        template_id: template_id
      )
    end

    it 'should generate a tenant and message representative reference' do
      expect(subject).to include(
        reference: reference
      )
    end
  end
end
