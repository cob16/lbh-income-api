module Hackney
  module Rent
    class SqlTenanciesMatchingCriteriaGateway
      GatewayModel = Hackney::Income::Models::CasePriority
      def criteria_for_green_in_arrears
        GatewayModel.criteria_for_green_in_arrears
      end
    end
  end
end
