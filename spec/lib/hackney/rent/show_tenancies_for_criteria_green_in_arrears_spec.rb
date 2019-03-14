require 'rails_helper'

describe Hackney::Rent::ShowTenanciesForCriteriaGreenInArrears do
  subject { show_green_in_arrears.execute }

  let(:sql_tenancies_for_messages_gateway) { instance_double(Hackney::Rent::SqlTenanciesMatchingCriteriaGateway) }

  let(:show_green_in_arrears) do
    described_class.new(
      sql_tenancies_for_messages_gateway: sql_tenancies_for_messages_gateway
    )
  end

  context 'when asking for a list of tenancies to send messages to' do
    it 'calls its gateway' do
      expect(sql_tenancies_for_messages_gateway).to receive(:criteria_for_green_in_arrears)
      subject
    end

    it 'returns results from the gateway' do
      expect(sql_tenancies_for_messages_gateway).to(
        receive(:criteria_for_green_in_arrears)
        .and_return(results: 'these')
      )
      expect(subject).to eq(results: 'these')
    end
  end
end
