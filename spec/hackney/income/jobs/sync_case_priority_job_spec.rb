require 'rails_helper'

describe Hackney::Income::Jobs::SyncCasePriorityJob do
  let(:tenancy_ref) { Faker::IDNumber.valid }
  subject { described_class }

  context 'when sync jobs are disabled' do
    before do
      allow_any_instance_of(Hackney::Income::Jobs::SyncCasePriorityJob)
        .to receive(:run_tenancy_sync_jobs?)
        .and_return(false)
    end

    it 'should not run use case' do
      expect_any_instance_of(Hackney::Income::SyncCasePriority).to_not receive(:execute)
      subject.perform_now(tenancy_ref: tenancy_ref)
    end
  end

  context 'whgen sync jobs are enabled' do
    before do
      allow_any_instance_of(Hackney::Income::Jobs::SyncCasePriorityJob)
        .to receive(:run_tenancy_sync_jobs?)
        .and_return(true)
    end

    it 'should construct the AssignTenancyToUser use case correctly' do
      expect(Hackney::Income::AssignTenancyToUser)
        .to receive(:new)
        .with(user_assignment_gateway: an_object_responding_to(:assign_to_next_available_user).with_keywords(:tenancy))
        .and_call_original

      subject.perform_now(tenancy_ref: tenancy_ref)
    end

    it 'should run the SyncCasePriority use case' do
      expect_any_instance_of(Hackney::Income::SyncCasePriority)
        .to receive(:execute)
        .with(tenancy_ref: tenancy_ref)

      subject.perform_now(tenancy_ref: tenancy_ref)
    end

    it 'should be able to be scheduled' do
      expect do
        subject.set(wait_until: Time.now + 5.minutes).perform_later
      end.to_not raise_error
    end
  end
end
