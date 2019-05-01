
module Hackney
  module Notification
    class ActionCode
      class << self
        def get_for_sms(template_id:)
          case template_id
          when Rails.configuration.x.green_in_arrears.sms_template_id
            Hackney::Tenancy::ActionCodes::AUTOMATED_SMS_ACTION_CODE
          when Rails.configuration.x.green_in_arrears.manual_sms_template_id
            Hackney::Tenancy::ActionCodes::MANUAL_GREEN_SMS_ACTION_CODE
          when Rails.configuration.x.amber_in_arrears.manual_sms_template_id
            Hackney::Tenancy::ActionCodes::MANUAL_AMBER_SMS_ACTION_CODE
          else
            warn("unknown sms template: #{template_id}")
            Hackney::Tenancy::ActionCodes::MANUAL_SMS_ACTION_CODE
          end
        end

        def get_for_email(template_id:)
          case template_id
          when Rails.configuration.x.green_in_arrears.email_template_id
            Hackney::Tenancy::ActionCodes::AUTOMATED_EMAIL_ACTION_CODE
          when Rails.configuration.x.green_in_arrears.manual_email_template_id
            Hackney::Tenancy::ActionCodes::MANUAL_GREEN_EMAIL_ACTION_CODE
          else
            warn("unknown email template: #{template_id}")
            Hackney::Tenancy::ActionCodes::MANUAL_EMAIL_ACTION_CODE
          end
        end

        private

        def warn(message)
          Rails.logger.warn('Notification::ActionCode') { message }
        end
      end
    end
  end
end

