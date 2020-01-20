module Stubs
  class StubCriteria
    def initialize(attributes = {})
      @attributes = attributes
    end

    def days_since_last_payment
      attributes[:days_since_last_payment]
    end

    def last_communication_date
      attributes[:last_communication_date]
    end

    def last_communication_action
      attributes[:last_communication_action]
    end

    def universal_credit
      attributes[:universal_credit]
    end

    def uc_rent_verification
      attributes[:uc_verification_complete]
    end

    def uc_direct_payment_requested
      attributes[:uc_direct_payment_requested]
    end

    def uc_direct_payment_received
      attributes[:uc_direct_payment_received]
    end

    def court_outcome
      attributes[:court_outcome]
    end

    def latest_active_agreement_date
      attributes[:latest_active_agreement_date]
    end

    def breach_agreement_date
      attributes[:breach_agreement_date]
    end

    def balance
      attributes[:balance]
    end

    def expected_balance
      attributes[:expected_balance] || 100.00
    end

    def weekly_rent
      attributes[:weekly_rent]
    end

    def weekly_service
      attributes[:weekly_service]
    end

    def weekly_other_charge
      attributes[:weekly_other_charge]
    end

    def weekly_gross_rent
      weekly_rent.to_i + weekly_service.to_i + weekly_other_charge.to_i
    end

    def nosp_served_date
      attributes[:nosp_served_date]
    end

    def nosp_expiry_date
      nosp[:expires_date]
    end

    def courtdate
      attributes[:courtdate]
    end

    def eviction_date
      attributes[:eviction_date]
    end

    def patch_code
      attributes[:patch_code]
    end

    def broken_court_order?
      attributes[:broken_court_order]
    end

    def days_in_arrears
      attributes[:days_in_arrears] || 7
    end

    def active_agreement?
      attributes[:most_recent_agreement] || attributes[:active_agreement]
    end

    def nosp_served?
      nosp[:served_date].present?
    end

    def nosp
      expires_date = nil
      valid_until_date = nil
      active = false
      in_cool_off_period = false
      valid = false

      if nosp_served_date.present?
        expires_date = nosp_served_date + 28.days
        valid_until_date = expires_date + 52.weeks
        active = expires_date < Time.zone.now
        in_cool_off_period = expires_date > Time.zone.now
        valid = valid_until_date > Time.zone.now
      end

      {
        served_date: nosp_served_date,
        expires_date: expires_date,
        valid_until_date: valid_until_date,
        active: valid && active,
        in_cool_off_period: in_cool_off_period,
        valid: valid
      }
    end

    def active_nosp?
      nosp[:active]
    end

    def number_of_broken_agreements
      attributes[:number_of_broken_agreements] || 0
    end

    def payment_ref
      attributes[:payment_ref]
    end

    def most_recent_agreement
      attributes[:most_recent_agreement]
    end

    private

    attr_reader :attributes
  end
end
