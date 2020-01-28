require 'rails_helper'

describe Hackney::Income::ShowSendSMSTenancies do
  subject { show_send_sms_tenancies.execute }

  let(:sql_tenancies_for_messages_gateway) { instance_double(Hackney::Income::SqlTenanciesMatchingCriteriaGateway) }

  let(:show_send_sms_tenancies) do
    described_class.new(
      sql_tenancies_for_messages_gateway: sql_tenancies_for_messages_gateway
    )
  end

  context 'when asking for a list of tenancies to send messages to' do
    it 'calls its gateway' do
      expect(sql_tenancies_for_messages_gateway).to receive(:send_sms_messages)
      subject
    end

    it 'returns results from the gateway' do
      expect(sql_tenancies_for_messages_gateway).to(
        receive(:send_sms_messages)
        .and_return(results: 'these')
      )
      expect(subject).to eq(results: 'these')
    end
  end
end
