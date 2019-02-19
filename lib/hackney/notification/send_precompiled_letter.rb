# FIXME: nest under Hackney::Notifications
module Hackney
  module Notification
    class SendPrecompiledLetter < Base
      def execute(user_id: nil, tenancy_ref: nil, unique_reference:, letter_pdf_location:)
        require 'pry'; binding.pry
        notification_gateway.send_precompiled_letter(
          unique_reference: unique_reference,
          letter_pdf_location: letter_pdf_location
        )

        # TODO: add action diary event if tenancy_ref
        if tenancy_ref
          # template_name = notification_gateway.get_template_name(template_id)
          # add_action_diary_usecase.execute(
          #   user_id: user_id,
          #   tenancy_ref: tenancy_ref,
          #   action_code: Hackney::Tenancy::ActionCodes::MANUAL_LETTER_ACTION_CODE,
          #   comment: "'#{unique_reference}' Letter sent to '#{recipient}'"
          # )
        end
      end
    end
  end
end
