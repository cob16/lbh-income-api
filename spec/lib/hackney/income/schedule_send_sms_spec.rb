require 'rails_helper'

describe Hackney::Income::ScheduleSendSMS do
  subject { sync_cases.execute }

  let(:matching_criteria_gateway) { double(Hackney::Income::SqlTenanciesMatchingCriteriaGateway) }
  let(:background_job_gateway) { double(Hackney::Income::BackgroundJobGateway) }

  let(:sync_cases) do
    described_class.new(
      matching_criteria_gateway: matching_criteria_gateway, background_job_gateway: background_job_gateway
    )
  end

  context 'when syncing cases' do
    context 'with no cases found' do
      before do
        expect(matching_criteria_gateway).to receive(:send_sms_messages).and_return([]).once
      end

      it 'queues no jobs' do
        expect(background_job_gateway).not_to receive(:send_sms_messages)
        subject
      end
    end

    context 'with cases found' do
      let(:case_priority_1) { create(:case_priority) }
      let(:case_priority_2) { create(:case_priority) }

      before do
        expect(matching_criteria_gateway).to receive(:send_sms_messages).and_return([case_priority_1, case_priority_2]).once
      end

      it 'queues a job to sync that case' do
        expect(background_job_gateway).to receive(:schedule_send_sms_msg).with(case_id: case_priority_1.case_id).once
        expect(background_job_gateway).to receive(:schedule_send_sms_msg).with(case_id: case_priority_2.case_id).once
        subject
      end
    end
  end
end
