module Hackney
  module PDF
    class GetTemplatesForUser
      LEASEHOLD_SERVICES_TEMPLATE_DIRECTORY_PATH = 'lib/hackney/pdf/templates/leasehold/'.freeze
      INCOME_COLLECTION_TEMPLATE_DIRECTORY_PATH = 'lib/hackney/pdf/templates/income/'.freeze

      def execute(user:)
        path = get_template_directory_path(user)

        Dir.glob(path).map do |f|
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
        File.basename(file_path, '.*').humanize
      end

      def get_template_id(file_path)
        File.basename(file_path, '.*')
      end

      def get_template_directory_path(user)
        paths = []
        paths << LEASEHOLD_SERVICES_TEMPLATE_DIRECTORY_PATH if user.leasehold_services?
        paths << INCOME_COLLECTION_TEMPLATE_DIRECTORY_PATH if user.income_collection?
        paths.map { |path| "#{path}*.erb" }
      end
    end
  end
end
