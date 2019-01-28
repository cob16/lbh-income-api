require 'rails_helper'

describe Hackney::Income::ScheduleGreenInArrearsMessage do
  let(:matching_criteria_gateway) { double(Hackney::Income::SqlTenanciesMatchingCriteriaGateway) }
  let(:background_job_gateway) { double(Hackney::Income::BackgroundJobGateway) }

  let(:sync_cases) do
    described_class.new(
      matching_criteria_gateway: matching_criteria_gateway, background_job_gateway: background_job_gateway
    )
  end

  subject { sync_cases.execute }

  context 'when syncing cases' do
    context 'and finding no cases' do
      before do
        expect(matching_criteria_gateway).to receive(:criteria_for_green_in_arrears).and_return([]).once
      end

      it 'should queue no jobs' do
        expect(background_job_gateway).not_to receive(:schedule_send_green_in_arrears_msg)
        subject
      end
    end

    context 'and finding cases' do
      let(:case_priority_1) { create(:case_priority) }
      let(:case_priority_2) { create(:case_priority) }

      before do
        expect(matching_criteria_gateway).to receive(:criteria_for_green_in_arrears).and_return([case_priority_1, case_priority_2]).once
      end

      it 'should queue a job to sync that case' do
        expect(background_job_gateway).to receive(:schedule_send_green_in_arrears_msg).with(case_id: case_priority_1.case_id).once
        expect(background_job_gateway).to receive(:schedule_send_green_in_arrears_msg).with(case_id: case_priority_2.case_id).once
        subject
      end
    end
  end
end
