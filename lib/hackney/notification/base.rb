module Hackney
  module Notification
    class Base
      attr_writer :notification_gateway, :add_action_diary_usecase

      def initialize(notification_gateway:, add_action_diary_usecase:)
        self.notification_gateway = notification_gateway
        self.add_action_diary_usecase = add_action_diary_usecase
      end

      def execute
        raise "#{self.class} execute not implemented"
      end

      private

      attr_reader :notification_gateway, :add_action_diary_usecase
    end
  end
end
