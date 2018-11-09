module Hackney
  module Income
    module Jobs
      class SyncCasePriorityJob < ApplicationJob
        queue_as :default

        def perform(tenancy_ref:)
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
