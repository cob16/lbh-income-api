require 'active_support'
module Hackney
  module Income
    module Jobs
      class SyncCasePriorityJob < ApplicationJob
        queue_as :uh_sync_cases

        # this is NOT a sync job!
        # this enqueues the job that enqueues all the sync jobs
        def perform(tenancy_ref:)
          ActiveSupport::Deprecation.warn(
            "SyncCasePriorityJob is deprecated - use external scheduler via 'rake income:sync:enqueue'"
          )

          if run_tenancy_sync_jobs?
            Rails.logger.info("Running '#{self.class.name}' for tenancy_ref: '#{tenancy_ref}'")
            income_use_case_factory.sync_case_priority.execute(tenancy_ref: tenancy_ref)
          else
            Rails.logger.info("Skipping '#{self.class.name}' job for tenancy_ref: '#{tenancy_ref}' as run_tenancy_sync_jobs is set false")
          end
        end
      end
    end
  end
end
