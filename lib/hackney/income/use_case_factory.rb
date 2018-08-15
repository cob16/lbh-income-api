module Hackney
  module Income
    class UseCaseFactory
      def view_my_cases
        Hackney::Income::DangerousViewMyCases.new(
          tenancy_api_gateway: Hackney::Income::TenancyApiGateway.new(
            host: ENV['INCOME_COLLECTION_API_HOST'],
            key: ENV['INCOME_COLLECTION_API_KEY']
          ),
          stored_tenancies_gateway: Hackney::Income::StoredTenanciesGateway.new
        )
      end

      def sync_cases
        Hackney::Income::DangerousSyncCases.new(
          prioritisation_gateway: Hackney::Income::UniversalHousingPrioritisationGateway.new,
          uh_tenancies_gateway: Hackney::Income::HardcodedTenanciesGateway.new,
          stored_tenancies_gateway: Hackney::Income::StoredTenanciesGateway.new
        )
      end
    end
  end
end
