module Hackney
  module PDF
    class Preview
      def initialize(get_templates_gateway:, leasehold_information_gateway:)
        @get_templates_gateway = get_templates_gateway
        @leasehold_information_gateway = leasehold_information_gateway
      end

      def execute(payment_ref:, template_id:, username:, user_groups:)
        template = get_template_by_id(template_id, user_groups)
        leasehold_info = get_leasehold_info(payment_ref)

        preview_with_errors = Hackney::PDF::PreviewGenerator.new(
          template_path: template[:path]
        ).execute(letter_params: leasehold_info, username: username)

        uuid = SecureRandom.uuid

        {
          case: leasehold_info,
          template: template,
          uuid: uuid,
          username: username,
          preview: preview_with_errors[:html],
          errors: preview_with_errors[:errors]
        }
      end

      private

      def get_leasehold_info(payment_ref)
        @leasehold_information_gateway.get_leasehold_info(payment_ref: payment_ref)
      end

      def get_template_by_id(template_id, user_groups)
        templates = @get_templates_gateway.execute(user_groups: user_groups)
        templates[templates.index { |temp| temp[:id] == template_id }]
      end
    end
  end
end
