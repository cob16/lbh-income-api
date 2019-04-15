require 'rails_helper'

describe Hackney::Income::UniversalHousingLeaseholdGateway, universal: true do
  let(:gateway) { described_class.new }

  after { truncate_uh_tables }

  describe '#get_leasehold_info' do
    context 'when payment_ref does not exist' do
      it 'returns empty' do
        expect(gateway.get_leasehold_info(payment_ref: 123)).to be_empty
      end
    end

    context 'when payment_ref exists' do
      let(:payment_ref) { Random.rand(100).to_s }
      let(:tenancy_ref) { Random.rand(100).to_s }
      let(:house_ref) { Random.rand(100).to_s }

      let(:corr_preamble) { 'Corr Preamble' }
      let(:cur_bal) { Random.rand(100) }

      let(:corr_desig) { 'Corr Desig' }
      let(:aline1){ 'Address line 1'}
      let(:aline2){ 'Address line 2'}
      let(:aline3){ 'Address line 3'}
      let(:aline4){ 'Address line 4'}
      let(:post_code) { Faker::Address.postcode }

      # let(:sc_leasedate) { Faker::Date.forward(23) }

      it 'get the prop_ref' do
        create_uh_tenancy_agreement(tenancy_ref: tenancy_ref, u_saff_rentacc: payment_ref,
                                    house_ref: house_ref,
                                    cur_bal: cur_bal)

        create_uh_househ(house_ref: house_ref, corr_preamble: corr_preamble,
                         corr_desig: corr_desig, post_code: post_code, corr_postcode: post_code)

        create_uh_postcode(post_code: post_code, aline1: aline1, aline2: aline2, aline3: aline3, aline4: aline4)

        result = gateway.get_leasehold_info(payment_ref: payment_ref)

        expect(result).to eq(tenancy_ref: tenancy_ref,
                             balance: cur_bal,
                             correspondence_address_1: corr_preamble,
                             correspondence_address_2: corr_desig + ' - ' + aline1,
                             correspondence_address_3: aline2,
                             correspondence_address_4: aline3,
                             correspondence_address_5: aline4,
                             correspondence_address_6: post_code,
                             original_lease_date: sc_leasedate
                             )

      #   househ.corr_desig + postcode.aline1
      end
    end
  end
end

# {
# OK  tenancy_ref: sc_case.fetch('tenancy_ref'),
# OK  correspondence_address1: sc_case.fetch('correspondence_address_1'),
# OK  correspondence_address2: sc_case.fetch('correspondence_address_2'),
# OK  correspondence_address3: sc_case.fetch('correspondence_address_3'),
# OK  correspondence_postcode: sc_case.fetch('correspondence_postcode'),
#
#   property_address: sc_case.fetch('property_address'),
#
#   payment_ref: sc_case.fetch('payment_ref'),
# OK  balance: sc_case.fetch('balance'),
#   collectable_arrears_balance: sc_case.fetch('collectable_arrears_balance'),
#   lba_expiry_date: sc_case.fetch('lba_expiry_date'),
#   original_lease_date: sc_case.fetch('original_lease_date'), - original_lease_date = rent.sc_leasedate
#   date_of_current_purchase_assignment: sc_case.fetch('date_of_current_purchase_assignment'),
#   original_leaseholders: sc_case.fetch('original_Leaseholders'),
#   full_names_of_current_lessees: sc_case.fetch('full_names_of_current_lessees'),
#   previous_letter_sent: sc_case.fetch('previous_letter_sent'),
#   arrears_letter_1_date: sc_case.fetch('arrears_letter_1_date'),
#   international: international?(sc_case.fetch('correspondence_postcode'))
# }
