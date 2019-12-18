require 'rails_helper'

describe "seeing letters' classification change after sync", type: :request do
  let(:property_ref) { Faker::Number.number(4) }
  let(:tenancy_ref) { "#{Faker::Number.number(6)}/#{Faker::Number.number(2)}" }
  let(:payment_ref) { Faker::Number.number(4) }
  let(:house_ref) { Faker::Number.number(4) }
  let(:postcode) { Faker::Address.postcode }
  let(:leasedate) { Time.zone.now.beginning_of_hour }
  let(:template) { 'income_collection_letter_1' }
  let(:user_group) { 'income-collection-group' }
  let(:current_balance) { BigDecimal('525.00') }

  let(:user) {
    {
      name: Faker::Name.name,
      email: Faker::Internet.email,
      groups: %w[leasehold-group income-group]
    }
  }
  # set up a case that needs a letter one sent

  before do
    create_valid_uh_records_for_a_letter
  end

  describe 'POST /api/v1/messages/letters/send' do
    let(:income_collection_letter) {
      generate_and_store_letter(tenancy_ref: tenancy_ref, template_id: template_id, user: user)
    }

    post messages_letters_send_path, params: {
      uuid: SecureRandom.uuid

    }
    reponse.body
    # look at the case and check it's got the right data
    get "cases/#{id}"

    expect(response.body[:case][:classification]).to eq('no_action')
  end

  def create_valid_uh_records_for_an_income_letter
    create_uh_property(
      property_ref: property_ref,
      post_code: postcode
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
      corr_preamble: 'Test',
      corr_desig: 'Test',
      corr_postcode: postcode,
      house_desc: 'Test Name'
    )
    create_uh_postcode(
      post_code: postcode,
      aline1: 'Test Line 1',
      aline2: 'Test Line 2'
    )
    create_uh_member(
      house_ref: house_ref,
      title: 'Test Title',
      forename: 'Test Forename',
      surname: 'Test Surname'
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
