module Hackney
  module Notification
    class SendPrecompiledLetter
      def initialize(notification_gateway:)
        @notification_gateway = notification_gateway
      end

      def execute(unique_reference:, letter_pdf:)
        @notification_gateway.send_precompiled_letter(
          unique_reference: unique_reference,
          letter_pdf: letter_pdf
        )
      end
    end
  end
end
