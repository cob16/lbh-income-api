module Hackney
  module PDF
    class UseCaseFactory
      def get_templates
        Hackney::PDF::GetTemplates.new
      end

      def get_preview
        Hackney::PDF::Preview.new(
          get_templates_gateway: get_templates,
          leasehold_information_gateway: Hackney::Income::UniversalHousingLeaseholdGateway.new,
          users_gateway: Hackney::Income::SqlUsersGateway.new
        )
      end
    end
  end
end
