module Hackney
  module Income
    class ShowSendSMSTenancies
      def initialize(sql_tenancies_for_messages_gateway:)
        @sql_tenancies_for_messages_gateway = sql_tenancies_for_messages_gateway
      end

      def execute
        @sql_tenancies_for_messages_gateway.send_sms_messages
      end
    end
  end
end
