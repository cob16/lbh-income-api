module Hackney
  module Income
    class UniversalHousingTenanciesGateway
      def tenancies_in_arrears
        database[:tenagree].where { cur_bal > 0 }.map(:tag_ref).map(&:strip)
      end

      private

      def database
        Hackney::UniversalHousing::Client.connection.tap do |db|
          db.extension :identifier_mangling
          db.identifier_input_method = db.identifier_output_method = nil
        end
      end
    end
  end
end
