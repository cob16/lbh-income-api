module Hackney
  module Income
    class UniversalHousingIncomeGateway
      def get_tenancy_ref(tenancy_ref:)
        with_core do |core|
          core.get_tenancy_ref(tenancy_ref: tenancy_ref)
        end
      end

      def get_income_info(tenancy_ref:)
        with_core do |core|
          core.get_income_info(tenancy_ref: tenancy_ref)
        end
      end

      private

      def with_core
        Hackney::UniversalHousing::Client.with_connection do |database|
          database.extension :identifier_mangling
          database.identifier_input_method = database.identifier_output_method = nil

          yield DatabaseBlock.new(database)
        end
      end

      class DatabaseBlock
        attr_reader :database

        def initialize(database)
          @database = database
        end

        def get_tenancy_ref(tenancy_ref:)
          res = tenancy_agreement
                .where(u_saff_rentacc: tenancy_ref)
                .first

          raise TenancyNotFoundError unless res.present?
          { tenancy_ref: res[:tag_ref] }
        end

        def get_leasehold_info(tenancy_ref:) # old
          res = tenancy_agreement
                .select_append(Sequel.qualify(:tenagree, :prop_ref).as(:tenancy_prop_ref))
                .select_append(Sequel.qualify(:tenagree, :tenure).as(:tenure_type))
                .where(u_saff_rentacc: tenancy_ref)
                .exclude(Sequel.trim(Sequel.qualify(:tenagree, :prop_ref)) => '')
                .join(rent, prop_ref: Sequel.qualify(:tenagree, :prop_ref))
                .join(household, house_ref: Sequel.qualify(:tenagree, :house_ref))
                .first

          raise TenancyNotFoundError unless res.present?

          prop_ref = res[:tenancy_prop_ref]

          property_res = property.first(prop_ref: prop_ref) || {}
          corr_address = get_correspondence_address(
            corr_postcode: res[:corr_postcode],
            prop_postcode: property_res[:post_code],
            household_res: res,
            property_res: property_res
          )

          {
            tenancy_ref: tenancy_ref,
            tenancy_ref: res[:tag_ref].strip,
            total_collectable_arrears_balance: res[:cur_bal],
            lessee_full_name: res[:house_desc]&.strip,
            lessee_short_name: res[:house_desc]&.strip,
            correspondence_address1: corr_address[:preamble]&.strip,
            correspondence_address2: "#{corr_address[:desig]&.strip} #{corr_address[:aline1]&.strip}",
            correspondence_address3: corr_address[:aline2]&.strip || '',
            correspondence_address4: corr_address[:aline3]&.strip || '',
            correspondence_address5: corr_address[:aline4]&.strip || '',
            correspondence_postcode: corr_address[:post_code]&.strip || '',
            property_address: "#{property_res[:address1]&.strip}, #{property_res[:post_code]&.strip}",
            international: international?(corr_address[:post_code])
          }
        end

        def get_income_info(tenancy_ref:)
          res = tenancy_agreement
                .select_append(Sequel.qualify(:postcode, :aline1).as(:address_line1))
                .select_append(Sequel.qualify(:postcode, :aline2).as(:address_line2))
                .select_append(Sequel.qualify(:postcode, :aline3).as(:address_line3))
                .select_append(Sequel.qualify(:postcode, :aline4).as(:address_line4))
                .select_append(Sequel.qualify(:postcode, :post_code).as(:address_post_code))
                .select_append(Sequel.qualify(:property, :prop_ref).as(:property_ref))
                .select_append(Sequel.qualify(:property, :post_preamble).as(:address_preamble))
                .select_append(Sequel.qualify(:property, :post_desig).as(:address_name_number))
                # .select_append(Sequel.qualify(:tenagree, :house_ref).as(:house_ref))
                .select_append(Sequel.qualify(:member, :title).as(:tenant_title))
                .select_append(Sequel.qualify(:member, :forename).as(:tenant_forename))
                .select_append(Sequel.qualify(:member, :surname).as(:tenant_surname))
                .exclude(Sequel.trim(Sequel.qualify(:property, :prop_ref)) => '')
                .join(property, post_code: Sequel.qualify(:postcode, :post_code))
                .join(tenagree, prop_ref: Sequel.qualify(:property, :prop_ref))
                .join(member, house_ref: Sequel.qualify(:tenagree, :house_ref))
                .where(tag_ref: tenancy_ref)
                .first
          byebug

          raise TenancyNotFoundError unless res.present?

          prop_ref = res[:tenancy_prop_ref]
          leasehold_res = get_leasehold_info(payment_ref)

          balance = leasehold_res[:total_collectable_arrears_balance]

          {
              tenant_title: tenant_title,
              tenant_forename: tenant_forename,
              tenant_surname: tenant_surname,
              address_line1: address_line1,
              address_line2: address_line2,
              address_line3: address_line3,
              address_line4: address_line4,
              address_post_code: address_post_code,
              property_ref: property_ref,
              address_preamble: address_preamble,
              address_name_number: address_name_number,

              total_collectable_arrears_balance: balance
          }
        end

        private

        def tenancy_agreement
          @tenancy_agreement ||= database[:tenagree]
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

        def household
          @household ||= database[:househ]
        end

        def get_correspondence_address(corr_postcode:, prop_postcode:, household_res:, property_res:)
          if corr_postcode.present?
            postcode.first(post_code: corr_postcode).presence&.merge(
              desig: household_res[:corr_desig],
              preamble: household_res[:corr_preamble]
            )
          elsif prop_postcode.present?
            postcode.first(post_code: prop_postcode).presence&.merge(
              desig: property_res[:post_desig],
              preamble: property_res[:post_preamble]
            )
          else
            {
              desig: household_res[:corr_desig],
              preamble: household_res[:corr_preamble]
            }
          end
        end

        def international?(postcode)
          postcode.nil? ? '' : !UKPostcode.parse(postcode).valid?
        end
      end
    end
    class TenancyNotFoundError < StandardError; end
  end
end
