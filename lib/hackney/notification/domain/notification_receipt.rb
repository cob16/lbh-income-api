module Hackney
  module Notification
    module Domain
      class NotificationReceipt
        attr_accessor :body, :message_id

        def initialize(body:, message_id: nil)
          @body = body
          @message_id = message_id
        end

        def body_without_newlines
          @body&.squish
        end
      end
    end
  end
end
