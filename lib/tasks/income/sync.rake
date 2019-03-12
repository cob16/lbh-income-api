namespace :rent do
  namespace :sync do
    # manual_sync and enqueue_sync are identical except enqueue_sync passes the load off to active_job
    desc 'enqueues workers for income_use_case_factory.schedule_sync_cases.execute'
    task :enqueue do
      use_case_factory = Hackney::Income::UseCaseFactory.new
      use_case_factory.schedule_sync_cases.execute
    end
  end
end
