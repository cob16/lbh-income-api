module Hackney
  module Income
    class UniversalHousingLeaseholdGateway
      def get_leasehold_info(payment_ref:)
        query = database[:tenagree]
        res = query.first(u_saff_rentacc: payment_ref)

        {
          tenancy_ref: res[:tag_ref]
        }
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
