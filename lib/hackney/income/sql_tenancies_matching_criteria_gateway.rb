module Hackney
  module Income
    class SqlTenanciesMatchingCriteriaGateway
      GatewayModel = Hackney::Income::Models::CasePriority
      def send_sms_messages
        GatewayModel.send_first_SMS
      end
    end
  end
end
