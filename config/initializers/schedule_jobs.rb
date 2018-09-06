if defined?(Rails::Server)
  # Scheduled tasks like SyncCasesJob should automatically re-queue their next run, if necessary.
  # This sets up these scheduled tasks for the first time if they haven't already been queued, when booting the application server.

  Delayed::Worker.logger = ActiveSupport::Logger.new(STDOUT)

  JobScheduler.enqueue_jobs if Rails.env.staging? or Rails.env.production?
end
