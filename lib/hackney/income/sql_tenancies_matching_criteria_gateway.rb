module Hackney
  module Income
    class SqlTenanciesMatchingCriteriaGateway
      GatewayModel = Hackney::Income::Models::CasePriority
      def send_sms_messages
        GatewayModel.send_sms_tenancies
      end
    end
  end
end
