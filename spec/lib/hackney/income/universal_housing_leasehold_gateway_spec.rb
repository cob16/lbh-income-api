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

      it 'get the prop_ref' do
        create_uh_tenancy_agreement(tenancy_ref: tenancy_ref, u_saff_rentacc: payment_ref)

        expect(gateway.get_leasehold_info(payment_ref: payment_ref)).to eq({ tenancy_ref: tenancy_ref })
      end
    end
  end
end

# {
# OK -  tenancy_ref: sc_case.fetch('tenancy_ref'),
#   correspondence_address1: sc_case.fetch('correspondence_address_1'),
#   correspondence_address2: sc_case.fetch('correspondence_address_2'),
#   correspondence_address3: sc_case.fetch('correspondence_address_3'),
#   correspondence_postcode: sc_case.fetch('correspondence_postcode'),
#   property_address: sc_case.fetch('property_address'),
#   payment_ref: sc_case.fetch('payment_ref'),
#   balance: sc_case.fetch('balance'),
#   collectable_arrears_balance: sc_case.fetch('collectable_arrears_balance'),
#   lba_expiry_date: sc_case.fetch('lba_expiry_date'),
#   original_lease_date: sc_case.fetch('original_lease_date'),
#   date_of_current_purchase_assignment: sc_case.fetch('date_of_current_purchase_assignment'),
#   original_leaseholders: sc_case.fetch('original_Leaseholders'),
#   full_names_of_current_lessees: sc_case.fetch('full_names_of_current_lessees'),
#   previous_letter_sent: sc_case.fetch('previous_letter_sent'),
#   arrears_letter_1_date: sc_case.fetch('arrears_letter_1_date'),
#   international: international?(sc_case.fetch('correspondence_postcode'))
# }
