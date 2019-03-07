module Hackney
  module PDF
    class PreviewGenerator
      MANDATORY_LETTER_FIELDS = %i[payment_ref lessee_full_name correspondence_address_1 correspondence_address_2
                                   correspondence_postcode property_address
                                   total_collectable_arrears_balance].freeze

      def initialize(template_path:)
        @template_path = template_path
        @errors = []
      end

      def execute(letter_params:)
        params = validate_mandatory_fields(letter_params)

        template = File.open(@template_path).read
        html = ERB.new(template).result(binding)

        [html, @errors]
      end

      private

      def validate_mandatory_fields(letter_params)
        MANDATORY_LETTER_FIELDS.each do |mandatory_field|
          next if letter_params[mandatory_field].present?
          @errors << {
            field: mandatory_field.to_s,
            error: 'missing mandatory field'
          }
        end
        letter_params[:lessee_short_name] = letter_params[:lessee_full_name] unless letter_params[:lessee_short_name].present?
        letter_params
      end
    end
  end
end
