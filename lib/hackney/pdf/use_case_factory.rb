module Hackney
  module PDF
    class UseCaseFactory
      TEMPLATE_DIRECTORY_PATH = 'lib/hackney/pdf/templates/'.freeze

      def get_templates
        Hackney::PDF::GetTemplates.new(
          template_directory_path: TEMPLATE_DIRECTORY_PATH
        )
      end

      def get_preview
        Hackney::PDF::Preview.new(
          get_templates_gateway: get_templates,
          leasehold_information_gateway: Hackney::ServiceCharge::UseCaseFactory.new.get_leasehold_information
        )
      end

      # TODO: FIX AND REMOVE
      # def generate_pdf
      #   generator = Hackney::PDF::PDFGateway.new
      #   html_preview = get_preview.html
      #   generator.generate_pdf(html_preview).to_pdf
      # end
    end
  end
end
