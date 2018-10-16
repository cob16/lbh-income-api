require 'rails_helper'

describe Hackney::Income::SqlLegalCasesGateway, universal: true do
  subject { described_class.new }

  after { truncate_uh_tables }

  context 'given a patch, get all tenancies above stage 4' do
    before do
      create_uh_tenancy_agreement_with_property(tenancy_ref: 'not_a_legal_case', prop_ref: '1234', arr_patch: 'W01')
      create_uh_tenancy_agreement_with_property(tenancy_ref: '1234/01', high_action: '4RS', prop_ref: '0987', arr_patch: 'E01')
      create_uh_tenancy_agreement_with_property(tenancy_ref: '1234/02', high_action: '5RP', prop_ref: '0986', arr_patch: 'E01')
      create_uh_tenancy_agreement_with_property(tenancy_ref: '1234/03', high_action: '6RC', prop_ref: '0985', arr_patch: 'E01')
      create_uh_tenancy_agreement_with_property(tenancy_ref: '1234/04', high_action: '6RO', prop_ref: '0984', arr_patch: 'E01')
      create_uh_tenancy_agreement_with_property(tenancy_ref: '1234/05', high_action: '7RE', prop_ref: '0983', arr_patch: 'E01')
    end

    it 'should return the tenancy refs for that patch' do
      expect(subject.get_tenancies_for_legal_process_for_patch(patch: 'E01')).to eq(
        [
          '1234/01',
          '1234/02',
          '1234/03',
          '1234/04',
          '1234/05',
        ]
      )
    end
  end

  context 'given a patch with no tenancies with a high_action above stage 4' do
    before do
      create_uh_tenancy_agreement_with_property(tenancy_ref: '1234/01', high_action: '111', prop_ref: '0987', arr_patch: 'E01')
      create_uh_tenancy_agreement_with_property(tenancy_ref: '1234/02', high_action: '111', prop_ref: '0986', arr_patch: 'W02')
      create_uh_tenancy_agreement_with_property(tenancy_ref: '1234/03', high_action: '111', prop_ref: '0985', arr_patch: 'E02')
      create_uh_tenancy_agreement_with_property(tenancy_ref: '1234/04', high_action: '111', prop_ref: '0984', arr_patch: 'E02')
    end

    it 'should return an empty array' do
      expect(subject.get_tenancies_for_legal_process_for_patch(patch: 'E01')).to eq([])
      expect(subject.get_tenancies_for_legal_process_for_patch(patch: 'E02')).to eq([])
      expect(subject.get_tenancies_for_legal_process_for_patch(patch: 'W02')).to eq([])
    end
  end
end
