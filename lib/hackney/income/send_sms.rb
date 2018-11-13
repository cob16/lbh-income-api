module Hackney
  module Income
    class SendSms
      def initialize(notification_gateway:)
        @notification_gateway = notification_gateway
        # @events_gateway = events_gateway
      end

      def execute(tenancy_ref:, template_id:, phone_number:, reference:, variables:)
        @notification_gateway.send_text_message(
          phone_number: phone_number,
          template_id: template_id,
          reference: reference,
          variables: variables
        )

        # tenancy = Hackney::Income::Models::Tenancy.find_by(tenancy_ref: tenancy_ref)

        # @events_gateway.create_event(
        #   tenancy_ref: tenancy_ref,
        #   type: 'sms_message_sent',
        #   description: "Sent SMS message to #{contact_number_for(tenancy)}",
        #   automated: false
        # )
      end
    end
  end
end
