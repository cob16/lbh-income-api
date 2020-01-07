require 'rails_helper'
require 'notifications/client'
require 'schedules/tenancy_sync'

describe 'syncing triggers automatic sending of letters', type: :feature do
  include MockAwsHelper
  include ActiveJob::TestHelper

  let(:tenancy_ref) { "#{Faker::Number.number(6)}/#{Faker::Number.number(2)}" }
  let(:payment_ref) { Faker::Number.number(4) }
  let(:current_balance) { BigDecimal('525.00') }
  let!(:original_env_can_auto_letters) { ENV['CAN_AUTOMATE_LETTERS'] }
  let!(:original_env_patch_codes_letters) { ENV['PATCH_CODES_FOR_LETTER_AUTOMATION'] }
  let!(:original_env_can_auto_letter_one) { ENV['AUTOMATE_INCOME_COLLECTION_LETTER_ONE'] }
  let(:income_use_case_factory) { Hackney::Income::UseCaseFactory.new }
  let(:case_priority) { Hackney::Income::Models::CasePriority.last }
  let(:gov_notify_client) { double(Notifications::Client) }
  let(:fake_response) {
    OpenStruct.new(
      id: Faker::Number.number,
      reference: SecureRandom.uuid,
      postage: 'second'
    )
  }

  let(:allowed_jobs) { [Hackney::Income::Jobs::SyncCasePriorityJob, Hackney::Income::Jobs::SendLetterToGovNotifyJob] }

  before do
    mock_aws_client
    create_valid_uh_records_for_an_income_letter
    mock_gov_notify_client

    ENV['CAN_AUTOMATE_LETTERS'] = 'true'
    ENV['AUTOMATE_INCOME_COLLECTION_LETTER_ONE'] = 'true'
    ENV['PATCH_CODES_FOR_LETTER_AUTOMATION'] = 'W02'
  end

  after do
    ENV['CAN_AUTOMATE_LETTERS'] = original_env_can_auto_letters
    ENV['PATCH_CODES_FOR_LETTER_AUTOMATION'] = original_env_patch_codes_letters
    ENV['AUTOMATE_INCOME_COLLECTION_LETTER_ONE'] = original_env_can_auto_letter_one
  end

  context 'when the cron job runs' do
    before do
      stub_action_diary_write
      set_other_balances_to_zero
    end

    it 'will sync the case priority and send the letter automatically' do
      when_the_sync_runs(document_count_changes_by: 1, case_priority_count_changes_by: 1)
      then_a_document_is_queued
      then_the_case_priority_is(:no_action)
    end

    context 'when a tenant enters into arrears' do
      let(:current_balance) { 0 }

      it 'will automatically send letter one' do
        given_a_case_exists
        given_a_case_priority_is(:no_action)
        when_the_tenancy_balance_in_uh_is(balance: 350)
        when_the_sync_runs(document_count_changes_by: 1, case_priority_count_changes_by: 0)
        then_a_document_is_queued
        then_the_case_priority_is(:no_action)
      end
    end

    context 'when the flag for letter 1 automation is false' do
      before do
        ENV['AUTOMATE_INCOME_COLLECTION_LETTER_ONE'] = 'false'
      end

      it 'will not automatically send letter one' do
        when_the_sync_runs(document_count_changes_by: 0, case_priority_count_changes_by: 1)
        then_the_case_priority_is(:send_letter_one)
      end
    end

    context 'when automation is turned off' do
      before do
        ENV['CAN_AUTOMATE_LETTERS'] = 'false'
      end

      it 'will not automatically send letter one' do
        when_the_sync_runs(document_count_changes_by: 0, case_priority_count_changes_by: 1)
        then_the_case_priority_is(:send_letter_one)
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
    property_ref = Faker::Number.number(4)
    house_ref = Faker::Number.number(4)
    postcode = Faker::Address.postcode
    leasedate = Time.zone.now.beginning_of_hour

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
      corr_preamble: 'Flat 5 Gingerbread House',
      corr_desig: '98',
      corr_postcode: postcode,
      house_desc: 'Test House Name'
    )
    create_uh_postcode(
      post_code: postcode,
      aline1: 'Fairytale Lane',
      aline2: 'Faraway'
    )
    create_uh_member(
      house_ref: house_ref,
      title: 'Ms',
      forename: 'Fortuna',
      surname: 'Curname'
    )
    create_uh_rent(
      prop_ref: property_ref,
      sc_leasedate: leasedate
    )
  end

  def given_a_case_exists
    income_use_case_factory.sync_case_priority.execute(tenancy_ref: tenancy_ref)
  end

  def when_the_sync_runs(document_count_changes_by:, case_priority_count_changes_by:)
    expect {
      expect {
        perform_enqueued_jobs(only: allowed_jobs) do
          TenancySync.new.perform
        end
      }.to change { Hackney::Cloud::Document.count }.by(document_count_changes_by)
    }.to change { Hackney::Income::Models::CasePriority.count }.by(case_priority_count_changes_by)
  end

  def when_the_tenancy_balance_in_uh_is(balance:)
    Hackney::UniversalHousing::Client.connection[:tenagree]
                                     .where(tag_ref: tenancy_ref)
                                     .update(cur_bal: balance)
  end

  def expect_case_priority_to_be(classification)
    expect(case_priority.tenancy_ref).to eq(tenancy_ref)
    expect(case_priority).to send("be_#{classification}".to_sym)
  end

  def then_a_document_is_queued
    document = Hackney::Cloud::Document.last
    expect(JSON.parse(document.metadata)['payment_ref']).to eq(payment_ref)
    expect(document).to be_queued
  end

  def mock_gov_notify_client
    stub_const('Notifications::Client', gov_notify_client)
    allow(gov_notify_client).to receive(:new).and_return(gov_notify_client)
    allow(gov_notify_client)
      .to receive(:send_precompiled_letter)
      .and_return(
        OpenStruct.new(
          id: Faker::Number.number,
          reference: SecureRandom.uuid,
          postage: 'second'
        )  
      )
  end

  def set_other_balances_to_zero
    # UH Sim *may* have some data in it. Make sure any that is in it does
    # not trigger the Sync process.
    Hackney::UniversalHousing::Client.connection[:tenagree]
                                     .where(Sequel[:tenagree][:cur_bal] > 0)
                                     .exclude(tag_ref: tenancy_ref)
                                     .update(cur_bal: 0)
  end

  alias_method :given_a_case_priority_is, :expect_case_priority_to_be
  alias_method :then_the_case_priority_is, :expect_case_priority_to_be
end
