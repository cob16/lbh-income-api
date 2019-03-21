module Hackney
  module Notification
    class SendManualPrecompiledLetter < BaseManualGateway
      def execute(user_id: nil, payment_ref: nil, unique_reference:, letter_pdf:)
        notification_gateway.send_precompiled_letter(
          unique_reference: unique_reference,
          letter_pdf: letter_pdf
        )

        # TODO: add action diary event if payment_ref
      end
    end
  end
end
