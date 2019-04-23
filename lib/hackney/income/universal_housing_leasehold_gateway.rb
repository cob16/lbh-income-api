module Hackney
  module Income
    class UniversalHousingLeaseholdGateway
      def get_leasehold_info(payment_ref:)
        res = tenagree
              .where(u_saff_rentacc: payment_ref)
              .join(rent, prop_ref: :prop_ref)
              .join(househ, prop_ref: :prop_ref)
              .first

        raise TenancyNotFoundError unless res.present?

        prop_ref = res[:prop_ref]
        corr_postcode_res = postcode.first(post_code: res[:corr_postcode])
        property_res = property.first(prop_ref: prop_ref)

        {
          payment_ref: payment_ref,
          tenancy_ref: res[:tag_ref],
          balance: res[:cur_bal],
          original_lease_date: res[:sc_leasedate],
          lessee_full_name: res[:house_desc],
          lessee_short_name: get_short_name(res[:house_desc]),
          date_of_current_purchase_assignment: res[:cot],
          correspondence_address1: res[:corr_preamble],
          correspondence_address2: res[:corr_desig] + ' ' + corr_postcode_res[:aline1],
          correspondence_address3: corr_postcode_res[:aline2],
          correspondence_address4: corr_postcode_res[:aline3],
          correspondence_address5: corr_postcode_res[:aline4],
          correspondence_postcode: res[:corr_postcode],
          property_address: property_res[:address1] + ', ' + property_res[:post_code]
        }
      end

      private

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

      def get_short_name(full_name)
        full_name.split(' ').first
      end

      def database
        Hackney::UniversalHousing::Client.connection.tap do |db|
          db.extension :identifier_mangling
          db.identifier_input_method = db.identifier_output_method = nil
        end
      end
    end

    class TenancyNotFoundError < StandardError; end
  end
end
