module Hackney
  module PDF
    class GetTemplates
      LEASEHOLD_SERVICES_TEMPLATE_DIRECTORY_PATH = 'lib/hackney/pdf/templates/leasehold'.freeze
      INCOME_COLLECTION_TEMPLATE_DIRECTORY_PATH = 'lib/hackney/pdf/templates/income'.freeze
      LEASEHOLD_SERVICES_GROUP = 'leasehold-services-group-1'.freeze
      INCOME_COLLECTION_GROUP = 'income-collection-group-1'.freeze

      def execute(user_groups:)
        Dir.glob("#{get_template_directory_path(user_groups)}*.erb").map do |f|
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

      # TODO need to figure out what to do when a user belongs in both....
      def get_template_directory_path(groups)
        return LEASEHOLD_SERVICES_TEMPLATE_DIRECTORY_PATH if groups.include?(LEASEHOLD_SERVICES_GROUP)
        return INCOME_COLLECTION_TEMPLATE_DIRECTORY_PATH if groups.include?(INCOME_COLLECTION_GROUP)
      end
    end
  end
end
