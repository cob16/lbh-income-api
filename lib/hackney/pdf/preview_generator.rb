module Hackney
  module PDF
    class PreviewGenerator
      MANDATORY_LETTER_FIELDS = %i[payment_ref lessee_full_name correspondence_address_1 correspondence_address_2
                                   correspondence_postcode property_address
                                   total_collectable_arrears_balance].freeze

      LOGO_PATH = 'lib/hackney/pdf/templates/logo.svg'.freeze
      SENDER_ADDRESS_PATH = 'lib/hackney/pdf/templates/sender_address.erb'.freeze
      PAYMENT_OPTIONS_PATH = 'lib/hackney/pdf/templates/payment_options.erb'.freeze

      def initialize(template_path:)
        @template_path = template_path
        @errors = []
        @sending_date = get_date
        @logo = File.open(LOGO_PATH).read
      end

      def execute(letter_params:)
        params = validate_mandatory_fields(letter_params)

        @sender_address = ERB.new(File.open(SENDER_ADDRESS_PATH).read).result(binding)

        @payment_options = ERB.new(File.open(PAYMENT_OPTIONS_PATH).read).result(binding)

        template = File.open(@template_path).read
        html = ERB.new(template).result(binding)

        {
          html: html,
          errors: @errors
        }
      end

      private

      def get_date
        # FIX ME: figure out what date this exactly should be...
        Time.now.strftime('%d %B %Y')
      end

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
