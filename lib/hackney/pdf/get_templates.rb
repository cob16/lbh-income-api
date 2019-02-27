module Hackney
  module PDF
    class GetTemplates
      def initialize(template_directory_path:)
        @template_directory = template_directory_path
      end

      def execute
        Dir.glob("#{@template_directory}*.erb").map do |f|
          template_meta_data = get_meta_data(f)
          { path: f, name: template_meta_data[:name], id: template_meta_data[:id] }
        end
      end

      private

      def get_meta_data(file_path)
        {
          name: get_template_name(file_path),
          id: get_template_id(file_path)
        }
      end

      def get_template_name(file_path)
        file_path.split('/').last.split('.').first.tr('_', ' ').capitalize
      end

      def get_template_id(file_path)
        file_path.split('/').last.split('.').first
      end
    end
  end
end
