module Hackney
  module PDF
    class Preview
      def initialize(get_templates_gateway:, leasehold_information_gateway:)
        @get_templates_gateway = get_templates_gateway
        @leasehold_information_gateway = leasehold_information_gateway
      end

      def execute(payment_ref:, template_id:)
        template = get_template_by_id(template_id)
        leasehold_info = get_leasehold_info(payment_ref)

        preview_with_errors = Hackney::PDF::PreviewGenerator.new(
          template_path: template[:path]
        ).execute(letter_params: leasehold_info)

        uuid = SecureRandom.uuid

        save_to_cache(
          cache_key: uuid,
          cache_value: {
            case: leasehold_info,
            template: template,
            uuid: uuid,
            preview: preview_with_errors[:html],
            errors: preview_with_errors[:errors]
          }
        )
      end

      private

      def save_to_cache(cache_key:, cache_value:)
        Rails.cache.write(cache_key, cache_value, expires_in: 12.hours)
        cache_value
      end

      def get_leasehold_info(payment_ref)
        @leasehold_information_gateway.execute(payment_ref: payment_ref).first
      end

      def get_template_by_id(template_id)
        templates = @get_templates_gateway.execute
        templates[templates.index { |temp| temp[:id] == template_id }]
      end
    end
  end
end
