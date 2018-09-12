module Hackney
  module Income
    class DangerousViewMyCases
      def initialize(tenancy_api_gateway:, stored_tenancies_gateway:)
        @tenancy_api_gateway = tenancy_api_gateway
        @stored_tenancies_gateway = stored_tenancies_gateway
      end

      def execute(user_id:, page_number:, number_per_page:)
        stored_tenancies = @stored_tenancies_gateway.get_tenancies_for_user(user_id: user_id, page_number: page_number, number_per_page: number_per_page)
        stored_tenancy_refs = stored_tenancies.map { |t| t.fetch(:tenancy_ref) }
        full_tenancies = @tenancy_api_gateway.get_tenancies_by_refs(stored_tenancy_refs)

        stored_tenancies.map do |stored_tenancy|
          tenancy = full_tenancies.find { |t| t.fetch(:ref) == stored_tenancy.fetch(:tenancy_ref) }
          next if tenancy.nil?

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

            balance_contribution: stored_tenancy.fetch(:balance_contribution),
            days_in_arrears_contribution: stored_tenancy.fetch(:days_in_arrears_contribution),
            days_since_last_payment_contribution: stored_tenancy.fetch(:days_since_last_payment_contribution),
            payment_amount_delta_contribution: stored_tenancy.fetch(:payment_amount_delta_contribution),
            payment_date_delta_contribution: stored_tenancy.fetch(:payment_date_delta_contribution),
            number_of_broken_agreements_contribution: stored_tenancy.fetch(:number_of_broken_agreements_contribution),
            active_agreement_contribution: stored_tenancy.fetch(:active_agreement_contribution),
            broken_court_order_contribution: stored_tenancy.fetch(:broken_court_order_contribution),
            nosp_served_contribution: stored_tenancy.fetch(:nosp_served_contribution),
            active_nosp_contribution: stored_tenancy.fetch(:active_nosp_contribution),

            balance: stored_tenancy.fetch(:balance),
            days_in_arrears: stored_tenancy.fetch(:days_in_arrears),
            days_since_last_payment: stored_tenancy.fetch(:days_since_last_payment),
            payment_amount_delta: stored_tenancy.fetch(:payment_amount_delta),
            payment_date_delta: stored_tenancy.fetch(:payment_date_delta),
            number_of_broken_agreements: stored_tenancy.fetch(:number_of_broken_agreements),
            active_agreement: stored_tenancy.fetch(:active_agreement),
            broken_court_order: stored_tenancy.fetch(:broken_court_order),
            nosp_served: stored_tenancy.fetch(:nosp_served),
            active_nosp: stored_tenancy.fetch(:active_nosp)
          }
        end.compact
      end
    end
  end
end
