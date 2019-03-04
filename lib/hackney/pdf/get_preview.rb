module Hackney
  module PDF
    class GetPreview
      def initialize(get_templates_gateway:, get_case_by_refs_gateway:)
        @get_templates_gateway = get_templates_gateway
        @get_case_by_refs_gateway = get_case_by_refs_gateway
      end

      def execute(payment_ref:, template_id:)
        template = get_template_path(template_id)
        sc_case = @get_case_by_refs_gateway.execute(payment_ref: payment_ref).first

        html = Hackney::PDF::PDFGenerator.new(
          template_path: template[:path],
          pdf_gateway: 12
        ).execute(letter_params: sc_case)

        {
          case: sc_case,
          template: template,
          preview: html
        }
      end

      private

      def get_template_path(template_id)
        @get_templates_gateway.execute.select { |temp| temp[:id] == template_id }.first
      end
    end
  end
end
