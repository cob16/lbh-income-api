module Hackney
  module PDF
    class IncomePreview
      def initialize(get_templates_gateway:, income_information_gateway:)
        @get_templates_gateway = get_templates_gateway
        @income_information_gateway = income_information_gateway
      end

      def execute(tenancy_ref:, template_id:, user:)
        template = get_template_by_id(template_id, user)
        income_info = get_income_info(tenancy_ref)

        preview_with_errors = Hackney::PDF::IncomePreviewGenerator.new(
          template_path: template[:path]
        ).execute(letter_params: income_info, username: user.name)

        uuid = SecureRandom.uuid

        {
          case: income_info,
          template: template,
          uuid: uuid,
          username: user.name,
          preview: preview_with_errors[:html],
          errors: preview_with_errors[:errors]
        }
      end

      private

      def get_income_info(tenancy_ref)
        @income_information_gateway.get_income_info(tenancy_ref: tenancy_ref)
      end

      def get_template_by_id(template_id, user)
        templates = @get_templates_gateway.execute(user: user)
        templates[templates.index { |temp| temp[:id] == template_id }]
      end
    end
  end
end
