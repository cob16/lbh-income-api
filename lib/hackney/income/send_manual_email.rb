module Hackney
  module Income
    class SendManualEmail
      def initialize(notification_gateway:, add_action_diary_usecase:)
        # @tenancy_gateway = tenancy_gateway
        @notification_gateway = notification_gateway
        @add_action_diary_usecase = add_action_diary_usecase
      end

      def execute(user_id:, tenancy_ref:, recipient:, template_id:, reference:, variables:)
        @notification_gateway.send_email(
          recipient: recipient,
          template_id: template_id,
          reference: reference,
          variables: variables
        )
        template_name = @notification_gateway.get_template_name(template_id)
        @add_action_diary_usecase.execute(
          user_id: user_id,
          tenancy_ref: tenancy_ref,
          action_code: Hackney::Tenancy::ActionCodes::MANUAL_EMAIL_ACTION_CODE,
          comment: "'#{template_name}' Email sent to '#{recipient}'"
        )
      end
    end
  end
end
