module Hackney
  module Income
    module Jobs
      class SyncCasesJob < ApplicationJob
        queue_as :default

        def self.next_run_time
          Date.tomorrow.midnight + 3.hours
        end

        def perform
          income_use_case_factory.sync_cases.execute
        rescue => e
          Rails.logger.error("Caught error: #{e}")
        ensure
          self.class.enqueue_next
        end
      end
    end
  end
end
