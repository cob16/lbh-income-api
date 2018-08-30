class JobScheduler
  def self.enqueue_jobs
    Hackney::Income::Jobs::SyncCasesJob.enqueue_next
  end
end
