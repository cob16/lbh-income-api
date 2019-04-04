module Hackney
  module PDF
    class PreviewGenerator

      LOGO_PATH = 'lib/hackney/pdf/templates/logo.svg'.freeze
      SENDER_ADDRESS_PATH = 'lib/hackney/pdf/templates/sender_address.erb'.freeze
      PAYMENT_OPTIONS_PATH = 'lib/hackney/pdf/templates/payment_options.erb'.freeze
      REPLY_FORM_PATH = 'lib/hackney/pdf/templates/reply_form.erb'.freeze

      def initialize(template_path:)
        @template_path = template_path
        @errors = []
        @sending_date = get_date
        @logo = File.open(LOGO_PATH).read
      end

      def execute(letter_params:)
        @letter = Hackney::ServiceCharge::Letter.new(letter_params)

        @sender_address = ERB.new(File.open(SENDER_ADDRESS_PATH).read).result(binding)

        @payment_options = ERB.new(File.open(PAYMENT_OPTIONS_PATH).read).result(binding)

        @reply_form = ERB.new(File.open(REPLY_FORM_PATH).read).result(binding)

        template = File.open(@template_path).read
        html = ERB.new(template).result(binding)

        {
          html: html,
          errors: @letter.errors
        }
      end

      private

      def get_date
        # FIX ME: figure out what date this exactly should be...
        Time.now.strftime('%d %B %Y')
      end
    end
  end
end
