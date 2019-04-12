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
          leasehold_information_gateway: Hackney::Income::UniversalHousingLeaseholdGateway.new
        # proposal: leasehold_information_gateway: Hackney::Income::UniversalHousingLeaseholdGateway
        )
      end
    end
  end
end
