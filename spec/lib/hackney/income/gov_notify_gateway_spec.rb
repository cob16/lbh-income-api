require 'rails_helper'

describe Hackney::Income::GovNotifyGateway do
  let(:sms_sender_id) { 'cool_sender_id' }
  let(:mock_gov_notify) { double(Notifications::Client) }
  let(:api_key) { 'FAKE_API_KEY-53822c9d-b17d-442d-ace7-565d08215d20-53822c9d-b17d-442d-ace7-565d08215d20' }
  let(:send_live_communications) { true }
  let(:test_phone_number) { Faker::PhoneNumber.phone_number }
  let(:test_email) { Faker::Internet.email }

  subject do
    described_class.new(
      sms_sender_id: sms_sender_id,
      api_key: api_key,
      send_live_communications: send_live_communications,
      test_phone_number: test_phone_number,
      test_email_address: test_email
    )
  end

  before do
    allow(Notifications::Client).to receive(:new)
      .with(api_key)
      .and_return(mock_gov_notify)
  end

  context 'when sending a text message to a live tenant' do
    let(:phone_number) { Faker::PhoneNumber.phone_number }

    it 'should send the message to the live phone number' do
      expect(mock_gov_notify).to receive(:send_sms).with(
        phone_number: phone_number,
        template_id: 'sweet-test-template-id',
        personalisation: {
          'first name' => 'Steven Leighton',
          'balance' => '-£100.00'
        },
        reference: 'amazing-test-reference',
        sms_sender_id: sms_sender_id
      )

      subject.send_text_message(
        phone_number: phone_number,
        template_id: 'sweet-test-template-id',
        variables: {
          'first name' => 'Steven Leighton',
          'balance' => '-£100.00'
        },
        reference: 'amazing-test-reference'
      )
    end
  end

  context 'when sending a text message to a tenant' do
    let(:send_live_communications) { false }

    it 'should send through Gov Notify' do
      expect(mock_gov_notify).to receive(:send_sms).with(
        phone_number: test_phone_number,
        template_id: 'sweet-test-template-id',
        personalisation: {
          'first name' => 'Steven Leighton',
          'balance' => '-£100.00'
        },
        reference: 'amazing-test-reference',
        sms_sender_id: sms_sender_id
      )

      subject.send_text_message(
        phone_number: 'I am a phone number that will be ignored',
        template_id: 'sweet-test-template-id',
        variables: {
          'first name' => 'Steven Leighton',
          'balance' => '-£100.00'
        },
        reference: 'amazing-test-reference'
      )
    end
  end

  context 'when retrieving a list of text message templates' do
    let(:template_id) { Faker::IDNumber.valid }

    it 'should return a list of sms templates' do
      expect(mock_gov_notify).to receive(:get_all_templates)
        .with(no_args)
        .and_return(
          Notifications::Client::TemplateCollection.new('templates' => [
            {
              'id' => template_id,
              'type' => 'sms',
              'created_at' => '2016-11-29T11:12:30.12354Z',
              'updated_at' => '2016-11-29T11:12:40.12354Z',
              'created_by' => 'jane.doe@gmail.com',
              'name' => 'template-name',
              'body' => 'hello ((first name)), how are you?',
              'version' => '2'
            }, {
              'id' => 'wibble',
              'type' => 'email',
              'created_at' => '2016-11-29T11:12:30.12354Z',
              'updated_at' => '2016-11-29T11:12:40.12354Z',
              'created_by' => 'jane.doe@gmail.com',
              'name' => 'template-name',
              'body' => 'hello ((first name)), how are you?',
              'version' => '2'
            }
          ])
        )

      expect(subject.get_templates(type: 'sms')).to eq([{
        id: template_id,
        type: 'sms',
        name: 'template-name',
        body: 'hello ((first name)), how are you?'
      }])
    end
  end

  context 'when sending an email to a tenant' do
    let(:send_live_communications) { false }

    it 'should send through Gov Notify' do
      expect(mock_gov_notify).to receive(:send_email).with(
        email_address: test_email,
        template_id: 'sweet-test-template-id',
        personalisation: {
          'first name' => 'Steven Leighton'
        },
        reference: 'amazing-test-reference'
      )

      subject.send_email(
        recipient: 'I am an email address that will be ignored',
        template_id: 'sweet-test-template-id',
        variables: {
          'first name' => 'Steven Leighton'
        },
        reference: 'amazing-test-reference'
      )
    end
  end

  context 'when retrieving a list of email templates' do
    let(:template_id) { Faker::IDNumber.valid }
    let(:other_template_id) { Faker::IDNumber.valid }

    it 'should memoize the templates list' do
      expect(mock_gov_notify).to receive(:get_all_templates)
        .with(no_args)
        .and_return(Notifications::Client::TemplateCollection.new('templates' => []))
        .once

      expect(subject.get_templates).to eq([])
      expect(subject.get_templates).to eq([])
    end

    it 'should return a list of templates' do
      expect(mock_gov_notify).to receive(:get_all_templates)
        .with(no_args)
        .and_return(
          Notifications::Client::TemplateCollection.new('templates' => [
              {
              'id' => template_id,
              'type' => 'email',
              'created_at' => '2016-11-29T11:12:30.12354Z',
              'updated_at' => '2016-11-29T11:12:40.12354Z',
              'created_by' => 'jane.doe@gmail.com',
              'name' => 'template-name',
              'body' => 'hello ((first name)), how are you?',
              'subject' => 'email subject',
              'version' => '2'
            }, {
              'id' => other_template_id,
              'type' => 'sms',
              'created_at' => '2016-11-29T11:12:30.12354Z',
              'updated_at' => '2016-11-29T11:12:40.12354Z',
              'created_by' => 'jane.doe@gmail.com',
              'name' => 'template-name',
              'body' => 'hello ((first name)), how are you?',
              'subject' => 'email subject',
              'version' => '2'
            }
          ])
        )

      expect(subject.get_templates(type: 'email')).to eq([{
        id: template_id,
        type: 'email',
        name: 'template-name',
        body: 'hello ((first name)), how are you?'
      }])
    end
  end

  context 'when getting a individual template by id' do
    let(:template_id) { SecureRandom.uuid }
    let(:other_template_id) { SecureRandom.uuid }

    it 'should return a template' do
      expect(mock_gov_notify).to receive(:get_all_templates)
        .with(no_args)
        .and_return(
          Notifications::Client::TemplateCollection.new('templates' => [
            {
              'id' => template_id,
              'type' => 'email',
              'created_at' => '2016-11-29T11:12:30.12354Z',
              'updated_at' => '2016-11-29T11:12:40.12354Z',
              'created_by' => 'jane.doe@gmail.com',
              'name' => 'template-name',
              'body' => 'hello ((first name)), how are you?',
              'subject' => 'email subject',
              'version' => '2'
            }, {
              'id' => other_template_id,
              'type' => 'sms',
              'created_at' => '2016-11-29T11:12:30.12354Z',
              'updated_at' => '2016-11-29T11:12:40.12354Z',
              'created_by' => 'jane.doe@gmail.com',
              'name' => 'template-name',
              'body' => 'hello ((first name)), how are you?',
              'subject' => 'email subject',
              'version' => '2'
            }
          ])
        )
      expect(subject.get_template_by_id(template_id)).to eq(
        id: template_id,
        type: 'email',
        name: 'template-name',
        body: 'hello ((first name)), how are you?'
      )
    end
  end
end
