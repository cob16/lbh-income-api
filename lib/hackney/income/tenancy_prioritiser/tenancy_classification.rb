module Hackney
  module Income
    class TenancyPrioritiser
      class TenancyClassification
        def initialize(criteria)
          @criteria = criteria
        end

        def execute
          return :send_NOSP if send_nosp?
          return :send_warning_letter if send_warning_letter?
          return :send_letter_two if send_letter_two?
          return :send_letter_one if send_letter_one?
          return :send_first_SMS if send_sms?
          :no_action
        end

        private

        def send_sms?
          @criteria.last_communication_action.nil? &&
            @criteria.balance >= 5 &&
            @criteria.balance < 10 &&
            @criteria.nosp_served == false &&
            last_communication_between_three_months_one_week? &&
            @criteria.paused == false
        end

        def send_letter_one?
          valid_actions = [
            Hackney::Tenancy::ActionCodes::GREEN_SMS_SENT_AUTO,
            Hackney::Tenancy::ActionCodes::GREEN_SMS_SENT_MANUAL
          ]

          @criteria.last_communication_action.in?(valid_actions) &&
            @criteria.balance > 10 &&
            @criteria.nosp_served == false &&
            last_communication_between_three_months_one_week? &&
            @criteria.paused == false
        end

        def send_letter_two?
          valid_actions = [
            Hackney::Tenancy::ActionCodes::LETTER_1_IN_ARREARS_AUTO,
            Hackney::Tenancy::ActionCodes::LETTER_1_IN_ARREARS_MANUAL
          ]

          @criteria.last_communication_action.in?(valid_actions) &&
            @criteria.balance >= @criteria.weekly_rent &&
            @criteria.balance < arrear_accumulation_by_number_weeks(3) &&
            @criteria.nosp_served == false &&
            last_communication_between_three_months_one_week? &&
            @criteria.paused == false
        end

        def send_warning_letter?
          valid_actions = [
            Hackney::Tenancy::ActionCodes::LETTER_2_IN_ARREARS_AUTO,
            Hackney::Tenancy::ActionCodes::LETTER_2_IN_ARREARS_MANUAL
          ]

          @criteria.last_communication_action.in?(valid_actions) &&
            @criteria.balance >= arrear_accumulation_by_number_weeks(3) &&
            @criteria.nosp_served == false &&
            last_communication_between_three_months_one_week? &&
            @criteria.paused == false
        end

        def send_nosp?
          valid_actions = [
            Hackney::Tenancy::ActionCodes::PRE_NOSP_WARNING_LETTER_AUTO,
            Hackney::Tenancy::ActionCodes::PRE_NOSP_WARNING_LETTER_MANUAL
          ]
          @criteria.last_communication_action.in?(valid_actions) &&
            @criteria.balance >= arrear_accumulation_by_number_weeks(4) &&
            @criteria.nosp_served == false &&
            last_communication_between_three_months_one_week? &&
            @criteria.paused == false
        end

        def last_communication_between_three_months_one_week?
          one_week = 7.days.ago.to_date
          three_months = 3.months.ago.to_date
          @criteria.last_communication_date <= one_week &&
            @criteria.last_communication_date >= three_months
        end

        def arrear_accumulation_by_number_weeks(weeks)
          @criteria.weekly_rent * weeks
        end
      end
    end
  end
end
