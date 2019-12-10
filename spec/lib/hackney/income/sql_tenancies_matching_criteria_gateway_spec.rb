require 'rails_helper'

describe Hackney::Income::SqlTenanciesMatchingCriteriaGateway do
  subject { described_class.new }

  let(:gateway_model) { described_class::GatewayModel }

  it 'returns an empty array when criteria do not match' do
    expect(subject.criteria_for_green_in_arrears).to eq([])
  end

  context 'when there are red and green tenancies' do
    before {
      create(:case_priority, classification: 'send_first_SMS')
      create(:case_priority, classification: 'send_letter_one')
      create(:case_priority, classification: 'send_first_SMS')
    }

    it 'returns only green tenancies' do
      expect(subject.criteria_for_green_in_arrears.count).to eq(2)
      expect(subject.criteria_for_green_in_arrears).to all(be_an(gateway_model))
    end
  end
end
