module Hackney
  module PDF
    class UseCaseFactory
      def get_templates
        Hackney::PDF::GetTemplatesForUser.new
      end

      def get_preview
        Hackney::PDF::Preview.new(
          get_templates_gateway: get_templates,
          leasehold_information_gateway: Hackney::Income::UniversalHousingLeaseholdGateway.new
        )
      end
    end
  end
end
