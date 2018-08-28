module Hackney
  module Income
    module Jobs
      class SyncCasesJob < ApplicationJob
        queue_as :default

        after_perform do
          self.class.set(wait_until: next_run_time).perform_later
        end

        def perform
          begin
            sync_cases.execute
          rescue
          end
        end

        def sync_cases
          Hackney::Income::DangerousSyncCases.new(
            prioritisation_gateway: Hackney::Income::UniversalHousingPrioritisationGateway.new,
            uh_tenancies_gateway: Hackney::Income::UniversalHousingTenanciesGateway.new,
            stored_tenancies_gateway: Hackney::Income::StoredTenanciesGateway.new
          )
        end

        def next_run_time
          Date.tomorrow.midnight + 3.hours
        end
      end
    end
  end
end
