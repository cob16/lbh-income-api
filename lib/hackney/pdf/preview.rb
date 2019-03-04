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

        html = Hackney::PDF::PreviewGenerator.new(
          template_path: template[:path]
        ).execute(letter_params: leasehold_info)

        {
          case: leasehold_info,
          template: template,
          preview: html
        }
      end

      private

      def get_leasehold_info(payment_ref)
        @leasehold_information_gateway.execute(payment_ref: payment_ref).first
      end

      def get_template_by_id(template_id)
        @get_templates_gateway.execute.select { |temp| temp[:id] == template_id }.first
      end
    end
  end
end
