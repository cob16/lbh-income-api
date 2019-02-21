module Hackney
  module Notification
    class SendAutomatedEmail
      def initialize(notification_gateway:, background_job_gateway:)
        @notification_gateway = notification_gateway
        @background_job_gateway = background_job_gateway
      end

      def execute(tenancy_ref:, recipient:, template_id:, reference:, variables:)
        @notification_gateway.send_email(
          recipient: recipient,
          template_id: template_id,
          reference: reference,
          variables: variables
        )
        template_name = @notification_gateway.get_template_name(template_id)
        @background_job_gateway.add_action_diary_entry(
          tenancy_ref: tenancy_ref,
          action_code: Hackney::Tenancy::ActionCodes::AUTOMATED_SMS_ACTION_CODE,
          comment: "'#{template_name}' email sent to '#{recipient}'"
        )
      end
    end
  end
end
