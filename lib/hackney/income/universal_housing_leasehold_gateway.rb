module Hackney
  module Income
    class UniversalHousingLeaseholdGateway
      def get_leasehold_info(payment_ref:)
        prop_ref = get_prop_ref(payment_ref)

        tenagree_res = tenagree.first(prop_ref: prop_ref)
        rent_res = rent.first(prop_ref: prop_ref)
        property_res = property.first(prop_ref: prop_ref)
        househ_res = househ.first(house_ref: tenagree_res[:house_ref])
        corr_postcode_res = postcode.first(post_code: househ_res[:corr_postcode])

        {
          tenancy_ref: tenagree_res[:tag_ref],
          balance: tenagree_res[:cur_bal],
          original_lease_date: rent_res[:sc_leasedate],
          correspondence_address_1: househ_res[:corr_preamble],
          correspondence_address_2: househ_res[:corr_desig] + ' - ' + corr_postcode_res[:aline1],
          correspondence_address_3: corr_postcode_res[:aline2],
          correspondence_address_4: corr_postcode_res[:aline3],
          correspondence_address_5: corr_postcode_res[:aline4],
          correspondence_address_6: househ_res[:corr_postcode],
          property_address_1: property_res[:post_preamble]
        }
      end

      private

      def get_prop_ref(payment_ref)
        u_letsvoids = database[:u_letsvoids].first(payment_ref: payment_ref)

        raise ArgumentError, 'payment_ref does not exist!' unless u_letsvoids.present?

        u_letsvoids[:prop_ref]
      end

      def tenagree
        @tenagree ||= database[:tenagree]
      end

      def postcode
        @postcode ||= database[:postcode]
      end

      def rent
        @rent ||= database[:rent]
      end

      def property
        @property ||= database[:property]
      end

      def househ
        @househ ||= database[:househ]
      end

      def database
        Hackney::UniversalHousing::Client.connection.tap do |db|
          db.extension :identifier_mangling
          db.identifier_input_method = db.identifier_output_method = nil
        end
      end
    end
  end
end
