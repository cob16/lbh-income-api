require 'rails_helper'

describe Hackney::Income::ScheduleGreenInArrearsMessage do
  subject { sync_cases.execute }

  let(:matching_criteria_gateway) { double(Hackney::Income::SqlTenanciesMatchingCriteriaGateway) }
  let(:background_job_gateway) { double(Hackney::Income::BackgroundJobGateway) }

  let(:sync_cases) do
    described_class.new(
      matching_criteria_gateway: matching_criteria_gateway, background_job_gateway: background_job_gateway
    )
  end

  context 'when syncing cases' do
    context 'without finding any cases' do
      before do
        expect(matching_criteria_gateway).to receive(:criteria_for_green_in_arrears).and_return([]).once
      end

      it 'queues no jobs' do
        expect(background_job_gateway).not_to receive(:schedule_send_green_in_arrears_msg)
        subject
      end
    end

    context 'when finding cases' do
      let(:tenancy_1) { create_tenancy_model }
      let(:tenancy_2) { create_tenancy_model }

      before do
        expect(matching_criteria_gateway).to receive(:criteria_for_green_in_arrears).and_return([tenancy_1, tenancy_2]).once
      end

      it 'queues a job to sync that case' do
        expect(background_job_gateway).to receive(:schedule_send_green_in_arrears_msg).with(tenancy_ref: tenancy_1.tenancy_ref, balance: tenancy_1.balance).once
        expect(background_job_gateway).to receive(:schedule_send_green_in_arrears_msg).with(tenancy_ref: tenancy_2.tenancy_ref, balance: tenancy_2.balance).once
        subject
      end
    end
  end
end
