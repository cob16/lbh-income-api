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
          @criteria.last_communication_date <= 7.days.ago.to_date &&
          @criteria.last_communication_date >= 3.months.ago.to_date &&
          @criteria.paused == false

        end

        def send_letter_one?
          @criteria.last_communication_action == Hackney::Tenancy::ActionCodes::TEXT_MESSAGE_SENT &&
            @criteria.balance > 10 &&
            @criteria.nosp_served == false &&
            @criteria.last_communication_date <= 7.days.ago.to_date &&
            @criteria.last_communication_date >= 3.months.ago.to_date &&
          @criteria.paused == false
        end

        def send_letter_two?
          @criteria.last_communication_action == Hackney::Tenancy::ActionCodes::FIRST_FTA_LETTER_SENT &&
            @criteria.balance >= @criteria.weekly_rent &&
            @criteria.balance < (@criteria.weekly_rent * 3) &&
            @criteria.nosp_served == false &&
            @criteria.last_communication_date <= 7.days.ago.to_date &&
            @criteria.last_communication_date >= 3.months.ago.to_date &&
          @criteria.paused == false

        end

        def send_warning_letter?
          @criteria.last_communication_action == Hackney::Tenancy::ActionCodes::LETTER_2_IN_ARREARS_LH &&
          @criteria.balance >= (@criteria.weekly_rent * 3) &&
          @criteria.nosp_served == false &&
          @criteria.last_communication_date <= 7.days.ago.to_date &&
          @criteria.last_communication_date >= 3.months.ago.to_date &&
          @criteria.paused == false

        end

        def send_nosp?
          @criteria.last_communication_action == 'ZW2' &&
          @criteria.balance >= (@criteria.weekly_rent * 4) &&
          @criteria.nosp_served == false &&
          @criteria.last_communication_date <= 7.days.ago.to_date &&
          @criteria.last_communication_date >= 3.months.ago.to_date &&
          @criteria.paused == false

        end
      end
    end
  end
end
