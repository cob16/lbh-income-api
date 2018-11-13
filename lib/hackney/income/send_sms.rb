module Hackney
  module Income
    class SendSms
      def initialize(notification_gateway:)
        @notification_gateway = notification_gateway
      end

      def execute(tenancy_ref:, template_id:, phone_number:, reference:, variables:)
        # something will be done with the tenancy_ref here later
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
