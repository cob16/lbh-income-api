module Hackney
  module Income
    class StoredTenanciesGateway
      def store_tenancy(tenancy_ref:, priority_band:, priority_score:, criteria:, weightings:)
        score_calculator = Hackney::Income::TenancyPrioritiser::Score.new(
          criteria,
          weightings,
        )

        Hackney::Income::Models::Tenancy.find_or_create_by(tenancy_ref: tenancy_ref).update(
          priority_band: priority_band,
          priority_score: priority_score,

          balance_contribution: score_calculator.balance,
          days_in_arrears_contribution: score_calculator.days_in_arrears,
          days_since_last_payment_contribution: score_calculator.days_since_last_payment,
          payment_amount_delta_contribution: score_calculator.payment_amount_delta,
          payment_date_delta_contribution: score_calculator.payment_date_delta,
          number_of_broken_agreements_contribution: score_calculator.number_of_broken_agreements,
          active_agreement_contribution: score_calculator.active_agreement,
          broken_court_order_contribution: score_calculator.broken_court_order,
          nosp_served_contribution: score_calculator.nosp_served,
          active_nosp_contribution: score_calculator.active_nosp,

          balance: criteria.balance,
          days_in_arrears: criteria.days_in_arrears,
          days_since_last_payment: criteria.days_since_last_payment,
          payment_amount_delta: criteria.payment_amount_delta,
          payment_date_delta: criteria.payment_date_delta,
          number_of_broken_agreements: criteria.number_of_broken_agreements,
          active_agreement: criteria.active_agreement?,
          broken_court_order: criteria.broken_court_order?,
          nosp_served: criteria.nosp_served?,
          active_nosp: criteria.active_nosp?
        )
      end

      def get_tenancies_by_refs(refs)
        Hackney::Income::Models::Tenancy.where('tenancy_ref in (?)', refs).map do |model|
          {
            tenancy_ref: model.tenancy_ref,
            priority_band: model.priority_band,
            priority_score: model.priority_score,

            balance_contribution: model.balance_contribution,
            days_in_arrears_contribution: model.days_in_arrears_contribution,
            days_since_last_payment_contribution: model.days_since_last_payment_contribution,
            payment_amount_delta_contribution: model.payment_amount_delta_contribution,
            payment_date_delta_contribution: model.payment_date_delta_contribution,
            number_of_broken_agreements_contribution: model.number_of_broken_agreements_contribution,
            active_agreement_contribution: model.active_agreement_contribution,
            broken_court_order_contribution: model.broken_court_order_contribution,
            nosp_served_contribution: model.nosp_served_contribution,
            active_nosp_contribution: model.active_nosp_contribution,

            balance: model.balance,
            days_in_arrears: model.days_in_arrears,
            days_since_last_payment: model.days_since_last_payment,
            payment_amount_delta: model.payment_amount_delta,
            payment_date_delta: model.payment_date_delta,
            number_of_broken_agreements: model.number_of_broken_agreements,
            active_agreement: model.active_agreement,
            broken_court_order: model.broken_court_order,
            nosp_served: model.nosp_served,
            active_nosp: model.active_nosp
          }
        end
      end
    end
  end
end
