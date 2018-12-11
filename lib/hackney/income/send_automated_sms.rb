require 'phonelib'

module Hackney
  module Income
    class SendAutomatedSms
      def initialize(notification_gateway:)
        @notification_gateway = notification_gateway
      end

      def execute(template_id:, phone_number:, reference:, variables:)
        phone = Phonelib.parse(phone_number)
        if phone.valid?
          @notification_gateway.send_text_message(
            phone_number: phone.full_e164,
            template_id: template_id,
            reference: reference,
            variables: variables
          )
        else
          # don't log the phone number to keep our logs free from personal data
          Rails.logger.warn("Invalid phone number when trying to send SMS for reference: '#{reference}' using template_id: #{template_id}, skipping")
        end
      end
    end
  end
end
