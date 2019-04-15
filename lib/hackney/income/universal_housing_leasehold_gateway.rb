module Hackney
  module Income
    class UniversalHousingLeaseholdGateway
      def get_leasehold_info(payment_ref:)
        tenagree = database[:tenagree]

        res = tenagree.inner_join(:househ, house_ref: :house_ref).first

        {
          tenancy_ref: res[:tag_ref],
          correspondence_address_1: res[:corr_preamble],
          balance: res[:cur_bal]
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
