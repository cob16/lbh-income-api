require 'rails_helper'

describe Hackney::Income::SqlTenanciesMatchingCriteriaGateway do
  subject { described_class.new }

  let(:gateway_model) { described_class::GatewayModel }

  it 'returns an empty array when criteria do not match' do
    create(:case_priority, classification: 'send_letter_one')
    create(:case_priority, classification: 'send_letter_two')

    expect(subject.send_sms_messages).to eq([])
  end

  context 'when there two send_first_SMS classification and one other classification' do
    before {
      create(:case_priority, classification: 'send_first_SMS')
      create(:case_priority, classification: 'send_letter_one')
      create(:case_priority, classification: 'send_first_SMS')
    }

    it 'returns only returns the send_SMS tenancies' do
      expect(subject.send_sms_messages.count).to eq(2)
      expect(subject.send_sms_messages).to all(be_an(gateway_model))
    end
  end
end
