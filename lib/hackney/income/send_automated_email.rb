module Hackney
  module Income
    class SendAutomatedEmail
      def initialize(notification_gateway:)
        @notification_gateway = notification_gateway
      end

      def execute(recipient:, template_id:, reference:, variables:)
        @notification_gateway.send_email(
          recipient: recipient,
          template_id: template_id,
          reference: reference,
          variables: variables
        )
      end
    end
  end
end
