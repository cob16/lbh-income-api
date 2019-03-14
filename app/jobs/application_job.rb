class ApplicationJob < ActiveJob::Base
  def rent_use_case_factory
    @rent_use_case_factory ||= Hackney::Rent::UseCaseFactory.new
  end

  def run_tenancy_sync_jobs?
    Rails.configuration.x.run_tenancy_sync_jobs
  end
end
