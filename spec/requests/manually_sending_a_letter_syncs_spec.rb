require 'rails_helper'
require 'notifications/client'
require 'schedules/tenancy_sync'

describe 'manually sending a letter causes case priority to sync', type: :request do
  include MockAwsHelper
  include ActiveJob::TestHelper

  let(:property_ref) { Faker::Number.number(4) }
  let(:tenancy_ref) { "#{Faker::Number.number(6)}/#{Faker::Number.number(2)}" }
  let(:payment_ref) { Faker::Number.number(4) }
  let(:house_ref) { Faker::Number.number(4) }
  let(:postcode) { Faker::Address.postcode }
  let(:leasedate) { Time.zone.now.beginning_of_hour }
  let(:template_id) { 'income_collection_letter_1' }
  let(:user_group) { 'income-collection-group' }
  let(:current_balance) { BigDecimal('525.00') }
  let(:gov_notify_client) { double(Notifications::Client) }
  let(:user) {
    {
      name: Faker::Name.name,
      email: Faker::Internet.email,
      groups: %w[leasehold-group income-group]
    }
  }
  let(:fake_response) {
    OpenStruct.new(
      id: Faker::Number.number,
      reference: SecureRandom.uuid,
      postage: 'second'
    )
  }

  let!(:original_env_can_auto_letters) { ENV['CAN_AUTOMATE_LETTERS'] }
  let!(:original_env_patch_codes_letters) { ENV['PATCH_CODES_FOR_LETTER_AUTOMATION'] }
  let!(:original_env_can_auto_letter_one) { ENV['AUTOMATE_INCOME_COLLECTION_LETTER_ONE'] }

  before do
    mock_aws_client
    create_valid_uh_records_for_an_income_letter

    stub_const('Notifications::Client', gov_notify_client)
    allow(gov_notify_client).to receive(:new).and_return(gov_notify_client)
    allow(gov_notify_client).to receive(:send_precompiled_letter).and_return(fake_response)

    ENV['CAN_AUTOMATE_LETTERS'] = 'true'
    ENV['PATCH_CODES_FOR_LETTER_AUTOMATION'] = 'W02'
    ENV['AUTOMATE_INCOME_COLLECTION_LETTER_ONE'] = 'true'
  end

  after do
    ENV['CAN_AUTOMATE_LETTERS'] = original_env_can_auto_letters
    ENV['PATCH_CODES_FOR_LETTER_AUTOMATION'] = original_env_patch_codes_letters
    ENV['AUTOMATE_INCOME_COLLECTION_LETTER_ONE'] = original_env_can_auto_letter_one
  end

  describe 'POST /api/v1/messages/letters/send' do
    let(:income_use_case_factory) { Hackney::Income::UseCaseFactory.new }
    let(:case_priority) { Hackney::Income::Models::CasePriority.last }

    context 'with existing income collection letter' do
      let(:income_collection_letter) {
        generate_and_store_letter(tenancy_ref: tenancy_ref, template_id: template_id, user: user)
      }

      before do
        income_collection_letter
        income_use_case_factory.sync_case_priority.execute(tenancy_ref: tenancy_ref)

        stub_action_diary_write
      end

      it 'updates the the classification when a user sends a letter' do
        expect(case_priority).to be_send_letter_one

        perform_enqueued_jobs(only: Hackney::Income::Jobs::SendLetterToGovNotifyJob) do
          post messages_letters_send_path, params: { uuid: income_collection_letter[:uuid] }
        end

        document = Hackney::Cloud::Document.find_by(uuid: income_collection_letter[:uuid])

        expect(document).to be_queued

        case_priority.reload
        expect(case_priority).to be_no_action
      end
    end
  end

  def stub_action_diary_write
    stub_request(
      :post,
      'http://example.com/api/v2/tenancies/arrears-action-diary'
    ).to_return(lambda do |_request|
      # Mock the behaviour of the API by writing directly to UH
      create_uh_action(tenancy_ref: tenancy_ref, code: 'IC1', date: Time.zone.now)

      { status: 200, body: '', headers: {} }
    end)
  end

  def create_valid_uh_records_for_an_income_letter
    create_uh_property(
      property_ref: property_ref,
      post_code: postcode,
      patch_code: 'W02'
    )
    create_uh_tenancy_agreement(
      tenancy_ref: tenancy_ref,
      u_saff_rentacc: payment_ref,
      prop_ref: property_ref,
      house_ref: house_ref,
      current_balance: current_balance
    )
    create_uh_househ(
      house_ref: house_ref,
      prop_ref: property_ref,
      corr_preamble: '23 Mockery House',
      corr_desig: '34',
      corr_postcode: postcode,
      house_desc: ''
    )
    create_uh_postcode(
      post_code: postcode,
      aline1: '4 Fake Street',
      aline2: 'Townt'
    )
    create_uh_member(
      house_ref: house_ref,
      title: 'Mrs',
      forename: 'Pauline',
      surname: 'Derrick'
    )
    create_uh_rent(
      prop_ref: property_ref,
      sc_leasedate: leasedate
    )
  end

  def generate_and_store_letter(tenancy_ref:, template_id:, user:)
    user_obj = Hackney::Domain::User.new.tap do |u|
      u.name = user[:name]
      u.email = user[:email]
      u.groups = user[:groups]
    end

    UseCases::GenerateAndStoreLetter.new.execute(
      tenancy_ref: tenancy_ref,
      payment_ref: nil,
      template_id: template_id,
      user: user_obj
    )
  end
end
