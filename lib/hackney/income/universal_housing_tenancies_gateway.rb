module Hackney
  module Income
    class UniversalHousingTenanciesGateway
      def tenancies_in_arrears
        database[:tenagree].where { cur_bal > 0 }.map(:tag_ref).map(&:strip)
      end

      private

      def database
        Hackney::UniversalHousing::Client.connection
      end
    end
  end
end
