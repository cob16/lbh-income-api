require 'rails_helper'

describe Hackney::Income::Jobs::SyncCasesJob do
  subject { described_class }

  context 'when sync jobs are disabled' do
    before do
      allow_any_instance_of(described_class)
      .to receive(:run_tenancy_sync_jobs?)
          .and_return(false)
    end

    it 'does not run use case' do
      expect_any_instance_of(Hackney::Income::ScheduleSyncCases).not_to receive(:execute)
      subject.perform_now
    end
  end

  context 'when sync jobs are enabled' do
    before do
      allow_any_instance_of(described_class)
      .to receive(:run_tenancy_sync_jobs?)
          .and_return(true)
    end

    it 'runs the ScheduleSyncCases use case' do
      expect_any_instance_of(Hackney::Income::ScheduleSyncCases).to receive(:execute).with(no_args)
      subject.perform_now
    end

    it 'is able to be scheduled' do
      expect do
        subject.set(wait_until: Time.now + 5.minutes).perform_later
      end.not_to raise_error
    end

    it 'stills schedule a new job for tomorrow on completion' do
      subject.perform_now
      expect(Delayed::Job.last).to have_attributes(run_at: next_expected_run_time)
    end

    context 'when the ScheduleSyncCases use case fails' do
      before do
        allow_any_instance_of(Hackney::Income::ScheduleSyncCases).to receive(:execute).and_raise('oh no!')
        subject.perform_later
      end

      it 'the job should still succeed and be removed from the queue' do
        job = Delayed::Job.first
        expect do
          Delayed::Worker.new.work_off
        end.to change {
          Delayed::Job.exists?(job.id)
        }.from(true).to(false)
      end

      it 'stills schedule a new job for tomorrow' do
        Delayed::Worker.new.work_off

        expect(Delayed::Job.last).to have_attributes(run_at: next_expected_run_time)
      end
    end
  end

  def next_expected_run_time
    Date.tomorrow.midnight + 3.hours
  end
end
