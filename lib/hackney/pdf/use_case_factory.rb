module Hackney
  module PDF
    class UseCaseFactory
      TEMPLATE_DIRECTORY_PATH = 'lib/hackney/pdf/templates/'.freeze

      def get_templates
        Hackney::PDF::GetTemplates.new(
          template_directory_path: TEMPLATE_DIRECTORY_PATH
        )
      end
    end
  end
end
