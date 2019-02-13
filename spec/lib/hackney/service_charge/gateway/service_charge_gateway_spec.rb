require 'rails_helper'

describe Hackney::ServiceCharge::Gateway::ServiceChargeGateway do
  let(:gateway) { described_class.new(host: 'https://example.com', key: 'skeleton') }

  context 'when retrieving service charge cases' do
    subject { gateway.get_cases_by_refs(refs) }

    context 'with a different host' do
      let(:gateway) { described_class.new(host: 'https://other.com', key: 'skeleton') }
      let(:refs) { %w[123] }

      before do
        stub_request(:get, 'https://other.com/api/v1/cases?tenancy_refs%5B%5D=123').with(
          headers: { 'x-api-key' => 'skeleton' }
        ).to_return(
          body: { 'cases' => [example_case] }.to_json
        )
      end

      it 'uses the host' do
        subject
        expect(WebMock).to have_requested(:get, 'https://other.com/api/v1/cases?tenancy_refs%5B%5D=123').once
      end
    end

    context 'when passing no case refs' do
      let(:refs) { [] }

      it 'gives no cases' do
        expect(subject).to be_empty
      end
    end

    context 'when the case has a ref' do
      let(:refs) { %w[456] }

      before do
        stub_request(:get, 'https://example.com/api/v1/cases?tenancy_refs%5B%5D=456').with(
          headers: { 'x-api-key' => 'skeleton' }
        ).to_return(
          body: { 'cases' => [example_case] }.to_json
        )
      end

      it 'gives basic details on that case' do
        expect(subject).to eq([{
                                 "tenancy_ref": "123",
                                 "correspondence_address_1": "742 Evergreen Terrace",
                                 "correspondence_address_2": "",
                                 "correspondence_address_3": "London",
                                 "correspondence_postcode": "E1 1HA",
                                 "property_address": "1 Hillman St, London, E8 1DY",
                                 "payment_ref": "1234567890",
                                 "balance": "2340.34",
                                 "collectable_arrears_balance": "293.99",
                                 "lba_expiry_date": "",
                                 "original_lease_date": "12/04/08",
                                 "date_of_current_purchase_assignment": "31/02/10",
                                 "original_Leaseholders": "Abe Simpson",
                                 "full_names_of_current_lessees": [
                                   "Homer Simpson",
                                   "Marge Simpson"
                                 ],
                                 "previous_letter_sent": "",
                                 "arrears_letter_1_date": ""
                               }])
      end
    end

    context 'with case containing nil values' do
      let(:refs) { %w[000017/01] }

      before do
        stub_request(:get, 'https://example.com/api/v1/cases?tenancy_refs%5B%5D=000017/01')
          .to_return(body: { 'cases' => [example_case_with_nils] }.to_json)
      end

      it 'nulls out the values completely' do
        expect(subject).to eq([{
                                 "tenancy_ref": "456",
                                 "correspondence_address_1": "31 Spooner Street",
                                 "correspondence_address_2": "Quahog",
                                 "correspondence_address_3": "Rhode Island",
                                 "correspondence_postcode": "02857",
                                 "property_address": "1 Hillman St, London, E8 1DY",
                                 "payment_ref": "0987654321",
                                 "balance": "2330.29",
                                 "collectable_arrears_balance": "200",
                                 "lba_expiry_date": nil,
                                 "original_lease_date": "12/04/03",
                                 "date_of_current_purchase_assignment": "02/12/13",
                                 "original_Leaseholders": "Peter Griffin",
                                 "full_names_of_current_lessees": [
                                   "Peter Griffin",
                                   "Lois Griffin"
                                 ],
                                 "previous_letter_sent": nil,
                                 "arrears_letter_1_date": nil
                               }])
      end
    end

    context 'with two case refs' do
      let(:refs) { %w[456 123] }

      before do
        stub_request(:get, 'https://example.com/api/v1/cases?tenancy_refs%5B%5D=456&tenancy_refs%5B%5D=123')
          .to_return(body: { 'cases' => [example_case_with_nils, example_case] }.to_json)
      end

      it 'includes both cases' do
        expect(subject.count).to eq(2)
      end

      it 'returns them in order' do
        ordered_refs = subject.map { |t| t.fetch(:tenancy_ref) }
        expect(ordered_refs).to eq(['456', '123'])
      end
    end
  end

  def example_case
    {
      "tenancy_ref": "123",
      "correspondence_address_1": "742 Evergreen Terrace",
      "correspondence_address_2": "",
      "correspondence_address_3": "London",
      "correspondence_postcode": "E1 1HA",
      "property_address": "1 Hillman St, London, E8 1DY",
      "payment_ref": "1234567890",
      "balance": "2340.34",
      "collectable_arrears_balance": "293.99",
      "lba_expiry_date": "",
      "original_lease_date": "12/04/08",
      "date_of_current_purchase_assignment": "31/02/10",
      "original_Leaseholders": "Abe Simpson",
      "full_names_of_current_lessees": [
        "Homer Simpson",
        "Marge Simpson"
      ],
      "previous_letter_sent": "",
      "arrears_letter_1_date": ""
    }
  end

  def example_case_with_nils
    {
      "tenancy_ref": "456",
      "correspondence_address_1": "31 Spooner Street",
      "correspondence_address_2": "Quahog",
      "correspondence_address_3": "Rhode Island",
      "correspondence_postcode": "02857",
      "property_address": "1 Hillman St, London, E8 1DY",
      "payment_ref": "0987654321",
      "balance": "2330.29",
      "collectable_arrears_balance": "200",
      "lba_expiry_date": nil,
      "original_lease_date": "12/04/03",
      "date_of_current_purchase_assignment": "02/12/13",
      "original_Leaseholders": "Peter Griffin",
      "full_names_of_current_lessees": [
        "Peter Griffin",
        "Lois Griffin"
      ],
      "previous_letter_sent": nil,
      "arrears_letter_1_date": nil
    }
  end
end
