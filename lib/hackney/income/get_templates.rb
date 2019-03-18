module Hackney
  module Income
    class GetTemplates
      def initialize(notification_gateway:)
        @notification_gateway = notification_gateway
      end

      def execute(type:)
        @notification_gateway.get_templates(
          type: type
        )
      end

      private

      def reference_for(tenancy)
        "manual_#{tenancy.ref}"
      end
    end
  end
end
