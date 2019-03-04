module Hackney
  module PDF
    class Preview
      def initialize(get_templates_gateway:, leasehold_information_gateway:)
        @get_templates_gateway = get_templates_gateway
        @leasehold_information_gateway = leasehold_information_gateway
      end

      def execute(payment_ref:, template_id:)
        template = get_template_by_id(template_id)
        sc_case = @leasehold_information_gateway.execute(payment_ref: payment_ref).first

        html = Hackney::PDF::PreviewGenerator.new(
          template_path: template[:path]
        ).execute(letter_params: sc_case)

        {
          case: sc_case,
          template: template,
          preview: html
        }
      end

      private

      def get_template_by_id(template_id)
        @get_templates_gateway.execute.select { |temp| temp[:id] == template_id }.first
      end
    end
  end
end
