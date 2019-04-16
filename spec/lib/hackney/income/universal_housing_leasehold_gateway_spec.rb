require 'rails_helper'

describe Hackney::Income::UniversalHousingLeaseholdGateway, universal: true do
  let(:gateway) { described_class.new }

  after { truncate_uh_tables }

  describe '#get_leasehold_info' do
    context 'when payment_ref does not exist' do
      it 'raises an exception' do
        expect{ gateway.get_leasehold_info(payment_ref: 123) }.to raise_exception('payment_ref does not exist!')
      end
    end

    context 'when payment_ref exists' do
      let(:payment_ref) { Random.rand(100).to_s }
      let(:tenancy_ref) { Random.rand(100).to_s }
      let(:house_ref) { Random.rand(100).to_s }

      let(:corr_preamble) { 'Corr Preamble' }
      let(:cur_bal) { Random.rand(100) }

      let(:corr_desig) { 'Corr Desig' }

      let(:corr_address) {
        {
          aline1: 'Address line 1',
          aline2: 'Address line 2',
          aline3: 'Address line 3',
          aline4: 'Address line 4',
          post_code: Faker::Address.postcode
        }
      }

      # let(:corr_postcode) { Faker::Address.postcode }
      let(:post_code) { Faker::Address.postcode }
      let(:prop_ref) { '123' }

      # Property address
      let(:post_preamble) { 'Post preamble' }

      let(:sc_leasedate) { Faker::Date.forward(23) }

      before do
        create_uh_u_letsvoids(payment_ref: payment_ref, prop_ref: prop_ref)
        create_uh_tenancy_agreement(tenancy_ref: tenancy_ref, u_saff_rentacc: payment_ref, house_ref: house_ref,
                                    cur_bal: cur_bal, prop_ref: prop_ref)
        create_uh_househ(house_ref: house_ref, prop_ref: prop_ref,
                         corr_preamble: corr_preamble, corr_desig: corr_desig,
                         post_code: post_code, corr_postcode: corr_address[:post_code])
        create_uh_postcode(corr_address)
        create_uh_rent(sc_leasedate: sc_leasedate, prop_ref: prop_ref)
        create_uh_property(property_ref: prop_ref, post_preamble: post_preamble)
      end

      it 'get the prop_ref' do
        result = gateway.get_leasehold_info(payment_ref: payment_ref)

        expect(result).to eq({
                               tenancy_ref: tenancy_ref,
                               balance: cur_bal,
                               original_lease_date: sc_leasedate
                             }.merge(correspondence_address)
                              .merge(property_address)
                             )

      # househ.corr_desig + postcode.aline1
      end
    end
  end

  def correspondence_address
    {
      correspondence_address_1: corr_preamble,
      correspondence_address_2: corr_desig + ' - ' + corr_address[:aline1],
      correspondence_address_3: corr_address[:aline2],
      correspondence_address_4: corr_address[:aline3],
      correspondence_address_5: corr_address[:aline4],
      correspondence_address_6: corr_address[:post_code]
    }
  end

  def property_address
    {
      property_address_1: post_preamble
    }
  end
end

# 1) property.post_preamble
# 2) property.post_desig + postcode.aline1
# 3) postcode.aline2
# 4) postcode.aline3
# 5) postcode.aline4
# 6) property.post_code
#



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
# NO  collectable_arrears_balance: sc_case.fetch('collectable_arrears_balance'),
# NO  lba_expiry_date: sc_case.fetch('lba_expiry_date'),
# OK  original_lease_date: sc_case.fetch('original_lease_date'), - original_lease_date = rent.sc_leasedate
#   date_of_current_purchase_assignment: sc_case.fetch('date_of_current_purchase_assignment'),
#   original_leaseholders: sc_case.fetch('original_Leaseholders'),
#   full_names_of_current_lessees: sc_case.fetch('full_names_of_current_lessees'),
#   previous_letter_sent: sc_case.fetch('previous_letter_sent'),
#   arrears_letter_1_date: sc_case.fetch('arrears_letter_1_date'),
#   international: international?(sc_case.fetch('correspondence_postcode'))


#
# 1) property.post_preamble
# 2) property.post_desig + postcode.aline1
# 3) postcode.aline2
# 4) postcode.aline3
# 5) postcode.aline4
# 6) property.post_code
