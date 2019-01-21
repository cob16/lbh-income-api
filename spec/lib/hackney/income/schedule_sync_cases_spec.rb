require 'rails_helper'

# TODO: RENAME from ScheduleSyncCases to descriptive schedule and delete
describe Hackney::Income::ScheduleSyncCases do
  let(:uh_tenancies_gateway) { double(tenancies_in_arrears: []) }
  let(:background_job_gateway) { double(schedule_case_priority_sync: nil) }
  let!(:removed_case_priority) { create(:case_priority) }

  # let(:case_priority_delete_gateway) { Hackney::Income::CasePriorityDeleteGateway }

  let(:sync_cases) do
    described_class.new(
      uh_tenancies_gateway: uh_tenancies_gateway,
      background_job_gateway: background_job_gateway
    )
  end

  subject { sync_cases.execute }

  context 'when syncing cases' do
    context 'and finding no cases' do
      it 'should queue no jobs' do
        expect(background_job_gateway).not_to receive(:schedule_case_priority_sync)
        subject
      end
    end

    context 'finding cases that aren\'t to be synced' do
      it 'should delete those case_priorities' do
        expect_any_instance_of(described_class).to receive(:delete_case_priorities_not_syncable).with(case_priorities: [removed_case_priority], tenancy_refs: [])

        subject
      end
    end

    context 'and finding a case' do
      let(:tenancy_ref) { Faker::IDNumber.valid }
      let(:uh_tenancies_gateway) { double(tenancies_in_arrears: [tenancy_ref]) }

      it 'should queue a job to sync that case' do
        expect(background_job_gateway).to receive(:schedule_case_priority_sync).with(tenancy_ref: tenancy_ref)
        subject
      end
    end

    context 'and finding a few cases' do
      let(:uh_tenancies_gateway) do
        double(tenancies_in_arrears: ['000010/01', '000011/01', '000012/01'])
      end

      it 'should queue a job for each case individually' do
        expect(background_job_gateway).to receive(:schedule_case_priority_sync).with(tenancy_ref: '000010/01')
        expect(background_job_gateway).to receive(:schedule_case_priority_sync).with(tenancy_ref: '000011/01')
        expect(background_job_gateway).to receive(:schedule_case_priority_sync).with(tenancy_ref: '000012/01')

        subject
      end
    end
  end
end
