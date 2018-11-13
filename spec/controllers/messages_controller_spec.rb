# frozen_string_literal: true

require 'rails_helper'
include MessagesHelper

describe MessagesController, type: :controller do
  let(:sms_params) do
    {
      tenancy_ref: "#{Faker::Number.number(8)}/#{Faker::Number.number(2)}",
      template_id: Faker::HitchhikersGuideToTheGalaxy.planet,
      phone_number: Faker::PhoneNumber.phone_number,
      reference: Faker::HitchhikersGuideToTheGalaxy.starship,
      variables: {
        'first name' => Faker::HitchhikersGuideToTheGalaxy.character
      }.to_s
    }
  end
  let(:email_params) do
    {
      tenancy_ref: "#{Faker::Number.number(8)}/#{Faker::Number.number(2)}",
      template_id: Faker::HitchhikersGuideToTheGalaxy.planet,
      email_address: Faker::Internet.email,
      reference: Faker::HitchhikersGuideToTheGalaxy.starship,
      variables: {
        'first name' => Faker::HitchhikersGuideToTheGalaxy.character
      }.to_s
    }
  end

  let(:stub_template) do
    [{
       "id": "#{Faker::Number.number(4)}-#{Faker::Number.number(4)}-#{Faker::Number.number(4)}-#{Faker::Number.number(4)}",
       "name":Faker::HitchhikersGuideToTheGalaxy.planet,
       "body": Faker::HitchhikersGuideToTheGalaxy.quote
     }]
  end

  before do
    stub_const(
      'Hackney::Income::GovNotifyGateway',
      StubGovNotifyGateway,
      transfer_nested_constants: true
    )
  end

  it 'sends an sms' do
    expect_any_instance_of(Hackney::Income::SendSms).to receive(:execute).with(
      tenancy_ref: sms_params.fetch(:tenancy_ref),
      template_id: sms_params.fetch(:template_id),
      phone_number: sms_params.fetch(:phone_number),
      reference: sms_params.fetch(:reference),
      variables: sms_params.fetch(:variables)
    ).and_call_original

    patch :send_sms, params: sms_params

    expect(response.status).to eq(204)
  end

  it 'sends an email' do
    expect_any_instance_of(Hackney::Income::SendEmail).to receive(:execute).with(
      tenancy_ref: email_params.fetch(:tenancy_ref),
      template_id: email_params.fetch(:template_id),
      recipient: email_params.fetch(:email_address),
      reference: email_params.fetch(:reference),
      variables: email_params.fetch(:variables)
    ).and_call_original

    patch :send_email, params: email_params

    expect(response.status).to eq(204)
  end

  it 'gets email templates' do
    expect_any_instance_of(Hackney::Income::GetTemplates).to receive(:execute).with(
      type: 'email'
    ).and_call_original

    patch :get_templates, params: {type: 'email'}

    expect(response.body).to eq(StubGovNotifyGateway::EXAMPLE_TEMPLATES.to_json)

  end

  it 'gets sms templates' do
    expect_any_instance_of(Hackney::Income::GetTemplates).to receive(:execute).with(
      type: 'sms'
    ).and_call_original

    patch :get_templates, params: {type: 'sms'}

    expect(response.body).to eq(StubGovNotifyGateway::EXAMPLE_TEMPLATES.to_json)
  end

end

class StubGovNotifyGateway

  EXAMPLE_TEMPLATES = example_templates

  def initialize(sms_sender_id:, api_key:); end

  def send_text_message(phone_number:, template_id:, reference:, variables:); end

  def send_email(recipient:, template_id:, reference:, variables:); end

  def get_templates(type:)
    EXAMPLE_TEMPLATES
  end

end
