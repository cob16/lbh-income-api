module Hackney
  module PDF
    class GetTemplates
      def initialize(template_directory_path:)
        @template_directory = template_directory_path
      end

      def execute
        Dir.glob("#{@template_directory}*.erb").map { |f| { path: f, name: get_template_name(f) } }
      end

      private

      def get_template_name(file_name)
        file_name.split('/').last.split('.').first.tr('_', ' ').capitalize
      end
    end
  end
end
