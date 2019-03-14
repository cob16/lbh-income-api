module Hackney
  module Rent
    class TenancyApiGatewayStub
      def initialize(tenancies_attributes)
        @tenancies_attributes = tenancies_attributes
      end

      def get_tenancies_by_refs(refs)
        refs.map { |ref| @tenancies_attributes[ref] }.compact
      end
    end
  end
end
