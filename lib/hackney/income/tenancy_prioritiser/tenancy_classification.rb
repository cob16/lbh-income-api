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
        end

        private

        def send_sms?
          if @criteria.balance > 5 &&
             @criteria.balance < 10 &&
             @criteria.nosp_served == false &&
             @criteria.last_communication_date < 7.days.ago.to_date &&
             @criteria.last_communication_date > 92.days.ago.to_date
            true
          end
        end

        def send_letter_one?
          if @criteria.last_communication_action == 'SMS' &&
             @criteria.balance > 10 &&
             @criteria.nosp_served == false &&
             @criteria.last_communication_date < 7.days.ago.to_date &&
             @criteria.last_communication_date > 92.days.ago.to_date
            true
          end
        end

        def send_letter_two?
          if @criteria.last_communication_action == 'C' &&
             @criteria.balance > @criteria.weekly_rent &&
             @criteria.balance < (@criteria.weekly_rent * 3) &&
             @criteria.nosp_served == false &&
             @criteria.last_communication_date < 7.days.ago.to_date &&
             @criteria.last_communication_date > 92.days.ago.to_date
            true
          end
        end

        def send_warning_letter?
          if @criteria.last_communication_action == 'LL2' &&
             @criteria.balance > (@criteria.weekly_rent * 3) &&
             @criteria.nosp_served == false &&
             @criteria.last_communication_date < 7.days.ago.to_date &&
             @criteria.last_communication_date > 92.days.ago.to_date
            true
          end
        end

        def send_nosp?
          if @criteria.last_communication_action == 'ZW2' &&
             @criteria.balance > (@criteria.weekly_rent * 4) &&
             @criteria.nosp_served == false &&
             @criteria.last_communication_date < 7.days.ago.to_date &&
             @criteria.last_communication_date > 92.days.ago.to_date
            true
          end
        end
      end
    end
  end
end
