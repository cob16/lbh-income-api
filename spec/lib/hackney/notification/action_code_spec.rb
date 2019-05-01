require 'rails_helper'

describe Hackney::Notification::ActionCode do
  let(:action_codes) { Hackney::Tenancy::ActionCodes }
  let(:template_id) { '' }

  describe '#get_for_sms' do
    let(:subject) { described_class.get_for_sms(template_id: template_id) }

    context 'With Manual Green SMS' do
      let(:template_id) { Rails.configuration.x.green_in_arrears.manual_sms_template_id }
      it { should eq(Hackney::Tenancy::ActionCodes::MANUAL_GREEN_SMS_ACTION_CODE) }
    end

    context 'With Manual Amber SMS' do
      let(:template_id) { Rails.configuration.x.amber_in_arrears.manual_sms_template_id }
      it { should eq(Hackney::Tenancy::ActionCodes::MANUAL_AMBER_SMS_ACTION_CODE) }
    end

    context 'With Automatic Green SMS' do
      let(:template_id) { Rails.configuration.x.green_in_arrears.sms_template_id }
      it { should eq(Hackney::Tenancy::ActionCodes::AUTOMATED_SMS_ACTION_CODE) }
    end

    context 'With unknown SMS' do
      let(:template_id) { 'fake-template-id' }

      it { should eq(Hackney::Tenancy::ActionCodes::MANUAL_GREEN_SMS_ACTION_CODE) }

      it 'Should send a warning to the logger' do
        expect(logger).to recieve(:warning).with("unknown sms template: #{template_id}")
      end
    end
  end

  describe '#get_for_email' do
    let(:subject) { described_class.get_for_sms(template_id: template_id) }

    context 'With Manual Green Email' do
      let(:template_id) { Rails.configuration.x.green_in_arrears.manual_email_template_id }
      it { should eq(Hackney::Tenancy::ActionCodes::MANUAL_GREEN_EMAIL_ACTION_CODE) }
    end

    context 'With Automatic Green Email' do
      let(:template_id) { Rails.configuration.x.green_in_arrears.email_template_id }
      it { should eq(Hackney::Tenancy::ActionCodes::AUTOMATED_EMAIL_ACTION_CODE) }
    end

    context 'With unknown Email' do
      let(:template_id) { 'fake-template-id' }

      it { should eq(Hackney::Tenancy::ActionCodes::MANUAL_GREEN_EMAIL_ACTION_CODE) }

      it 'Should send a warning to the logger' do
        expect(logger).to recieve(:warning).with("unknown email template: #{template_id}")
      end
    end
  end
end