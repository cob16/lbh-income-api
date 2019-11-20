require 'rails_helper'

RSpec.describe 'Income Collection Letters', type: :request do
  include MockAwsHelper

  let(:property_ref) { Faker::Number.number(4) }
  let(:tenancy_ref) { "#{Faker::Number.number(6)}/#{Faker::Number.number(2)}" }
  let(:payment_ref) { Faker::Number.number(4) }
  let(:house_ref) { Faker::Number.number(4) }
  let(:postcode) { Faker::Address.postcode }
  let(:leasedate) { Time.zone.now.beginning_of_hour }
  let(:template) { 'income_collection_letter_1' }
  let(:username) { Faker::Name.name }
  let(:email) { Faker::Internet.email }

  before do
    mock_aws_client
    create_valid_uh_records_for_an_income_letter
  end

  describe 'POST /api/v1/messages/letters' do
    it 'returns 404 with bogus tenancy ref' do
      post messages_letters_path, params: {
        tenancy_ref: 'abc', template_id: 'income_collection_letter_1', username: username, email: email
      }

      expect(response).to have_http_status(404)
    end

    it 'raises an error with bogus template_id' do
      expect {
        post messages_letters_path, params: {
          tenancy_ref: 'abc', template_id: 'does not exist', username: username, email: email
        }
      }.to raise_error(TypeError)
    end

    context 'with valid tenancy ref' do
      let(:expected_json_response_as_hash) {
        {
          'case' => {
            'tenancy_ref' => tenancy_ref,
            'payment_ref' => payment_ref,
            'address_line1' => 'Test Line 1',
            'address_line2' => 'Test Line 2',
            'address_line3' => '',
            'address_line4' => '',
            'address_name_number' => '',
            'address_post_code' => postcode,
            'address_preamble' => '',
            'property_ref' => property_ref,
            'forename' => 'Test Forename',
            'surname' => 'Test Surname',
            'title' => 'Test Title',
            'total_collectable_arrears_balance' => '0.0'
          },
          'template' => {
            'path' => 'lib/hackney/pdf/templates/income_collection_letter_1.erb',
            'name' => 'Income collection letter 1',
            'id' => 'income_collection_letter_1'
          },
          'username' => username,
          'document_id' => 1,
          'errors' => []
        }
      }

      it 'responds with a JSON object' do
        post messages_letters_path, params: {
          tenancy_ref: tenancy_ref, template_id: template, username: username, email: email
        }

        expect(response).to be_successful

        # UUID: is always different can ignore this.
        # TODO: Test `preview` content separatly
        keys_to_ignore = %w[preview uuid]

        json_response = JSON.parse(response.body).except(*keys_to_ignore)

        expect(json_response).to eq(expected_json_response_as_hash)
      end
    end
  end

  describe 'POST /api/v1/messages/letters/send' do
    let(:username) { Faker::Name.name }
    let(:email) { Faker::Internet.email }
    let(:existing_income_collection_letter) do
      generate_and_store_letter(
        tenancy_ref: tenancy_ref, template_id: template, username: username, email: email
      )
    end

    context 'when there is an existing income collection letter' do
      let(:uuid) { existing_income_collection_letter[:uuid] }

      before do
        existing_income_collection_letter
      end

      it 'is a No Content (204) status' do
        post messages_letters_send_path, params: { uuid: uuid, username: username, email: email }

        expect(response).to be_no_content
      end
    end
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
      house_ref: house_ref
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
    create_uh_rent(prop_ref: property_ref, sc_leasedate: leasedate)
  end

  def generate_and_store_letter(tenancy_ref:, template_id:, username:, email:)
    UseCases::GenerateAndStoreLetter.new.execute(
      tenancy_ref: tenancy_ref,
      payment_ref: nil,
      template_id: template_id,
      username: username,
      email: email
    )
  end
end
