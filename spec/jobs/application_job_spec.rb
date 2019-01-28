require 'rails_helper'

describe ApplicationJob do
  context 'when we enqueue_next' do
    it 'does not schedule again if already scheduled' do
      midnight_job = MidnightJob
      midnight_job.set(wait_until: midnight_job.next_run_time).perform_later

      expect { midnight_job.enqueue_next }.not_to(change { Delayed::Job.count })
    end

    it 'queues a job tomorrow noon' do
      LunchJob.enqueue_next
      expect(Delayed::Job.last).to have_attributes(run_at: Date.tomorrow.noon)
    end

    it 'queues a job tomorrow midnight' do
      MidnightJob.enqueue_next
      expect(Delayed::Job.last).to have_attributes(run_at: Date.tomorrow.midnight)
    end

    it 'raises an exception when next run time has not been set' do
      expect { NextRunNotDefinedJob.enqueue_next }.to raise_error(NotImplementedError)
    end
  end

  class NextRunNotDefinedJob < ApplicationJob; end

  class LunchJob < ApplicationJob
    def self.next_run_time
      Date.tomorrow.noon
    end
  end

  class MidnightJob < ApplicationJob
    def self.next_run_time
      Date.tomorrow.midnight
    end
  end
end
