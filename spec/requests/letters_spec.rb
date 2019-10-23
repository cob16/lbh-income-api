require 'rails_helper'

RSpec.describe 'Letters', type: :request do
  describe 'POST /api/v1/messages/letters' do
    it 'returns 404 with bogus payment ref' do
      post messages_letters_path, params: {
        payment_ref: 'abc', template_id: 'letter_1_in_arrears_FH'
      }

      expect(response).to have_http_status(404)
    end

    it 'raises an error with bogus template_id' do
      expect {
        post messages_letters_path, params: {
          payment_ref: 'abc', template_id: 'does not exist'
        }
      }.to raise_error(TypeError)
    end

    context 'with valid payment ref' do
      let(:property_ref) { Faker::Number.number(4) }
      let(:tenancy_ref) { "#{Faker::Number.number(6)}/#{Faker::Number.number(2)}" }
      let(:payment_ref) { Faker::Number.number(4) }
      let(:house_ref) { Faker::Number.number(4) }
      let(:postcode) { Faker::Address.postcode }
      let(:leasedate) { Time.zone.now.beginning_of_hour }

      let(:expected_json_response_as_hash) {
        {
          'case' => {
            'payment_ref' => payment_ref,
            'tenancy_ref' => tenancy_ref,
            'total_collectable_arrears_balance' => '0.0',
            'original_lease_date' => leasedate.strftime('%FT%T.%L%:z'),
            'lessee_full_name' => 'Test Name',
            'lessee_short_name' => 'Test Name', 'date_of_current_purchase_assignment' => '1900-01-01T00:00:00.000+00:00',
            'correspondence_address1' => 'Test',
            'correspondence_address2' => 'Test Test Line 1', 'correspondence_address3' => '',
            'correspondence_address4' => '',
            'correspondence_address5' => '',
            'correspondence_postcode' => postcode,
            'property_address' => ", #{postcode}",
            'international' => false
          },
          'template' => {
            'path' => 'lib/hackney/pdf/templates/letter_1_in_arrears_FH.erb',
            'name' => 'Letter 1 in arrears fh',
            'id' => 'letter_1_in_arrears_FH'
          },
          'errors' => []
        }
      }

      before do
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
          aline1: 'Test Line 1'
        )
        create_uh_rent(prop_ref: property_ref, sc_leasedate: leasedate)
      end

      it 'responds with a JSON object' do
        post messages_letters_path, params: {
          payment_ref: payment_ref, template_id: 'letter_1_in_arrears_FH'
        }

        # UUID: is always different can ignore this.
        # TODO: Test `preview` content separatly
        keys_to_ignore = %w[preview uuid]

        json_response = JSON.parse(response.body).except(*keys_to_ignore)

        expect(json_response).to eq(expected_json_response_as_hash)
      end
    end
  end
end
