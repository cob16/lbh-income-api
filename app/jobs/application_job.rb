class ApplicationJob < ActiveJob::Base
  def income_use_case_factory
    @income_use_case_factory ||= Hackney::Income::UseCaseFactory.new
  end

  def run_tenancy_sync_jobs?
    Rails.application.config.run_tenancy_sync_jobs
  end

  class << self
    def enqueue_next
      unless already_queued_for_next_run?
        set(wait_until: next_run_time).perform_later
      end
    end

    def next_run_time
      raise NotImplementedError
    end

    private

    def already_queued_for_next_run?
      Delayed::Job.any? do |next_job|
        next_job_data = YAML.load(next_job.handler).job_data
        name == next_job_data['job_class'] && next_run_time == next_job.run_at
      end
    end
  end
end
