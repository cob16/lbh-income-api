module Hackney
  module Income
    class SqlTenanciesForMessagesGateway
      def criteria_for_green_in_arrears
        Hackney::Income::Models::Tenancy.criteria_for_green_in_arrears
      end
    end
  end
end
