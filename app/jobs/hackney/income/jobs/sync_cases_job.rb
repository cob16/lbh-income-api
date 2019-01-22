module Hackney
  module Income
    module Jobs
      class SyncCasesJob < ApplicationJob
        queue_as :uh_sync_cases

        def self.next_run_time
          Date.tomorrow.midnight + 3.hours
        end

        # this is NOT a sync job!
        # this enqueues the job that enqueues all the sync jobs
        def perform
          ActiveSupport::Deprecation.warn(
            "SyncCasePriorityJob is deprecated - use external scheduler via 'rake income:sync:enqueue'"
          )
          if run_tenancy_sync_jobs?
            Rails.logger.info("Running '#{self.class.name}' job")
            begin
              income_use_case_factory.schedule_sync_cases.execute
            rescue StandardError => e
              Rails.logger.error("Caught error: #{e}")
            ensure
              self.class.enqueue_next
            end
          else
            Rails.logger.info("Skipping '#{self.class.name}' job as run_tenancy_sync_jobs is set false")
          end
        end
      end
    end
  end
end
