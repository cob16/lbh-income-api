module Hackney
  module Income
    class SendAutomatedSms
      def initialize(notification_gateway:)
        @notification_gateway = notification_gateway
      end

      def execute(template_id:, phone_number:, reference:, variables:)
        # TODO: verify number before sending
        @notification_gateway.send_text_message(
          phone_number: phone_number,
          template_id: template_id,
          reference: reference,
          variables: variables
        )
      end
    end
  end
end
