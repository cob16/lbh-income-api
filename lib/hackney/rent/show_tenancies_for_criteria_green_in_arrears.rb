module Hackney
  module Rent
    class ShowTenanciesForCriteriaGreenInArrears
      def initialize(sql_tenancies_for_messages_gateway:)
        @sql_tenancies_for_messages_gateway = sql_tenancies_for_messages_gateway
      end

      def execute
        @sql_tenancies_for_messages_gateway.criteria_for_green_in_arrears
      end
    end
  end
end
