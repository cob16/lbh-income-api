module Hackney
  module Income
    class SendEmail
      def initialize(notification_gateway:)
        # @tenancy_gateway = tenancy_gateway
        @notification_gateway = notification_gateway
      end

      def execute(tenancy_ref:, recipient:, template_id:, reference:, variables:)
        # tenancy = @tenancy_gateway.get_tenancy(tenancy_ref: tenancy_ref)
        # FIXME: currently not getting email addresses or saving!
        @notification_gateway.send_email(
          recipient: recipient,
          template_id: template_id,
          reference: reference,
          variables: variables
        )
      end

      private

      def reference_for(tenancy)
        "manual_#{tenancy.ref}"
      end
    end
  end
end
