# FIXME: nest under Hackney::Notifications
module Hackney
  module Notification
    class SendPrecompiledLetter < Base
      def execute(user_id: nil, payment_ref: nil, unique_reference:, letter_pdf_location:)
        notification_gateway.send_precompiled_letter(
          unique_reference: unique_reference,
          letter_pdf_location: letter_pdf_location
        )

        # TODO: add action diary event if payment_ref
      end
    end
  end
end
