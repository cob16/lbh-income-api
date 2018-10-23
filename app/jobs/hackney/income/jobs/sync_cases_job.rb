module Hackney
  module Income
    module Jobs
      class SyncCasesJob < ApplicationJob
        queue_as :default

        def self.next_run_time
          Date.tomorrow.midnight + 3.hours
        end

        def perform
          if run_tenancy_sync_jobs?
            Rails.logger.info("Running '#{self.class.name}' job")
            begin
              income_use_case_factory.sync_cases.execute
            rescue => e
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
