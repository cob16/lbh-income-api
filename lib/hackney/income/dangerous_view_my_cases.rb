module Hackney
  module Income
    class DangerousViewMyCases
      def initialize(tenancy_api_gateway:, stored_tenancies_gateway:)
        @tenancy_api_gateway = tenancy_api_gateway
        @stored_tenancies_gateway = stored_tenancies_gateway
      end

      def execute(tenancy_refs)
        full_tenancies = @tenancy_api_gateway.get_tenancies_by_refs(tenancy_refs)
        stored_tenancies = @stored_tenancies_gateway.get_tenancies_by_refs(tenancy_refs)

        full_tenancies.map do |tenancy, index|
          stored_tenancy = stored_tenancies.find { |t| t.fetch(:tenancy_ref) == tenancy.fetch(:ref) }

          {
            ref: tenancy.fetch(:ref),
            current_balance: tenancy.fetch(:current_balance),
            current_arrears_agreement_status: tenancy.fetch(:current_arrears_agreement_status),
            latest_action: {
              code: tenancy.dig(:latest_action, :code),
              date: tenancy.dig(:latest_action, :date),
            },
            primary_contact: {
              name: tenancy.dig(:primary_contact, :name),
              short_address: tenancy.dig(:primary_contact, :short_address),
              postcode: tenancy.dig(:primary_contact, :postcode),
            },
            priority_band: stored_tenancy.fetch(:priority_band),
            priority_score: stored_tenancy.fetch(:priority_score),
          }
        end
      end
    end
  end
end
