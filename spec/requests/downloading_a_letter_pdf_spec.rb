require 'rails_helper'

RSpec.describe 'Downloading a PDF', type: :request do
  include MockAwsHelper

  let(:real_template_id) { 'letter_before_action' }
  let(:payment_ref) { Faker::Number.number(6) }
  let(:house_ref) { Faker::Number.number(6) }
  let(:prop_ref) { Faker::Number.number(6) }
  let(:tenancy_ref) { Faker::Number.number(6) }
  let(:postcode) { Faker::Address.postcode }
  let(:email) { Faker::Internet.email }

  before do
    Timecop.freeze
    mock_aws_client
    create_valid_uh_records_for_a_letter

    stub_request(:post, 'http://example.com/api/v2/tenancies/arrears-action-diary')
  end

  after { Timecop.return }

  context 'when I call preview then documents' do
    before do
      post messages_letters_path, params: {
        payment_ref: payment_ref, template_id: real_template_id, username: username, email: email
      }

      letter_json = JSON.parse(response.body)
      get "/api/v1/documents/#{letter_json['document_id']}/download#{query_string}"
    end

    context 'with a username' do
      let(:username) { Faker::Name.name }
      let(:query_string) { "?username=#{username}" }

      it 'responds with a PDF' do
        expect(response.headers['Content-Type']).to eq('application/pdf')
      end

      it 'asks the tenancy API to record an action' do
        expect(a_request(
          :post, 'http://example.com/api/v2/tenancies/arrears-action-diary'
        )
            .with(body: {
              tenancyAgreementRef: tenancy_ref,
              actionCode: 'SLB',
              actionCategory: '9',
              comment: 'LBA sent (SC)',
              username: username,
              createdDate: DateTime.now.iso8601
            })).to have_been_made.once
      end
    end

    context 'without a username' do
      let(:username) { nil }
      let(:query_string) { "?username=#{username}" }

      it 'responds with a PDF' do
        expect(response.headers['Content-Type']).to eq('application/pdf')
      end

      it 'does not ask the tenancy API to record an action' do
        expect(a_request(
                 :post, 'http://example.com/api/v2/tenancies/arrears-action-diary'
               )).not_to have_been_made
      end
    end
  end

  def create_valid_uh_records_for_a_letter
    create_uh_property(
      property_ref: prop_ref,
      post_code: postcode
    )
    create_uh_tenancy_agreement(
      prop_ref: prop_ref,
      tenancy_ref: tenancy_ref,
      u_saff_rentacc: payment_ref,
      house_ref: house_ref
    )
    create_uh_househ(
      house_ref: house_ref,
      prop_ref: prop_ref,
      corr_preamble: 'address1',
      corr_desig: 'address2',
      corr_postcode: postcode,
      house_desc: 'Test Name'
    )
    create_uh_rent(
      prop_ref: prop_ref,
      sc_leasedate: ''
    )
    create_uh_postcode(
      post_code: postcode,
      aline1: ''
    )
  end
end
