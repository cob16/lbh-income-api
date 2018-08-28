module Hackney
  module Income
    module Jobs
      class SyncCasesJob < ApplicationJob
        queue_as :default

        def self.next_run_time
          Date.tomorrow.midnight + 3.hours
        end

        def perform
          sync_cases.execute
        rescue
        ensure
          self.class.enqueue_next
        end

        def sync_cases
          Hackney::Income::DangerousSyncCases.new(
            prioritisation_gateway: Hackney::Income::UniversalHousingPrioritisationGateway.new,
            uh_tenancies_gateway: Hackney::Income::UniversalHousingTenanciesGateway.new,
            stored_tenancies_gateway: Hackney::Income::StoredTenanciesGateway.new
          )
        end
      end
    end
  end
end
