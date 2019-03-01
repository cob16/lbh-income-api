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
        Hackney::PDF::GetPreview.new(
          get_templates_gateway: get_templates,
          get_case_by_refs_gateway: Hackney::ServiceCharge::UseCaseFactory.new.get_case_by_ref,
        )
      end
    end
  end
end
