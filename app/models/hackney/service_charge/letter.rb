module Hackney
  module ServiceCharge
    class Letter
      MANDATORY_LETTER_FIELDS = %i[payment_ref lessee_full_name
                                   correspondence_address_1 correspondence_address_2
                                   correspondence_postcode property_address
                                   total_collectable_arrears_balance].freeze

      attr_reader :tenancy_ref, :correspondence_address1, :correspondence_address2,
                  :correspondence_address3, :correspondence_postcode, :property_address,
                  :payment_ref, :balance, :total_collectable_arrears_balance,
                  :lba_expiry_date, :original_lease_date, :date_of_current_purchase_assignment,
                  :original_leaseholders, :previous_letter_sent, :arrears_letter_1_date,
                  :international, :lessee_full_name, :lessee_short_name, :errors

      def initialize(params)
        validated_params = validate_mandatory_fields(params)

        @tenancy_ref = validated_params[:tenancy_ref]
        @correspondence_address1 = validated_params[:correspondence_address1]
        @correspondence_address2 = validated_params[:correspondence_address2]
        @correspondence_address3 = validated_params[:correspondence_address3]
        @correspondence_postcode = validated_params[:correspondence_postcode]
        @property_address = validated_params[:property_address]
        @payment_ref = validated_params[:payment_ref]
        @balance = validated_params[:balance]
        @total_collectable_arrears_balance = validated_params[:total_collectable_arrears_balance]
        @lba_expiry_date = validated_params[:lba_expiry_date]
        @original_lease_date = validated_params[:original_lease_date]
        @date_of_current_purchase_assignment = validated_params[:date_of_current_purchase_assignment]
        @original_leaseholders = validated_params[:original_leaseholders]
        @previous_letter_sent = validated_params[:previous_letter_sent]
        @arrears_letter_1_date = validated_params[:arrears_letter_1_date]
        @international = validated_params[:international]
        @lessee_full_name = validated_params[:lessee_full_name]
        @lessee_short_name = validated_params[:lessee_short_name]
      end

      private

      def validate_mandatory_fields(letter_params)
        @errors = MANDATORY_LETTER_FIELDS
                  .reject { |field| letter_params[field].present? }
                  .map { |mandatory_field| { name: mandatory_field.to_s, message: 'missing mandatory field' } }

        letter_params[:lessee_short_name] = letter_params[:lessee_full_name] unless letter_params[:lessee_short_name].present?
        letter_params
      end
    end
  end
end
