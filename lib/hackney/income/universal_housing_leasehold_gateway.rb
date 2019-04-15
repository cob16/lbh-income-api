module Hackney
  module Income
    class UniversalHousingLeaseholdGateway
      def get_leasehold_info(payment_ref:)
        tenagree = database[:tenagree]

        res = tenagree.
          inner_join(:househ, house_ref: :house_ref).
          inner_join(:postcode, post_code: :post_code).first

        # househ.corr_desig + postcode.aline

        {
          tenancy_ref: res[:tag_ref],
          balance: res[:cur_bal],
          correspondence_address_1: res[:corr_preamble],
          correspondence_address_2: res[:corr_desig] + ' - ' + res[:aline1],
          correspondence_address_3: res[:aline2],
          correspondence_address_4: res[:aline3],
          correspondence_address_5: res[:aline4],
          correspondence_address_6: res[:corr_postcode],
          # correspondence_address_6: res[:aline3]

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
