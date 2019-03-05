module Hackney
  module PDF
    class PreviewGenerator
      def initialize(template_path:)
        @template_path = template_path
      end

      def execute(letter_params:)
        payment_ref = letter_params.fetch(:payment_ref)
        lessee_full_name = letter_params.fetch(:lessee_full_name)
        correspondence_address_one = letter_params.fetch(:correspondence_address_1)
        correspondence_address_two = letter_params.fetch(:correspondence_address_2)
        correspondence_address_three = letter_params.fetch(:correspondence_address_3)
        correspondence_postcode = letter_params.fetch(:correspondence_postcode)
        lessee_short_name = letter_params.fetch(:lessee_short_name)
        property_address = letter_params.fetch(:property_address)
        arrears_letter_1_date = letter_params.fetch(:arrears_letter_1_date)
        total_collectable_arrears_balance = letter_params.fetch(:total_collectable_arrears_balance)

        template = File.open(@template_path).read
        ERB.new(template).result(binding)
      end
    end
  end
end
