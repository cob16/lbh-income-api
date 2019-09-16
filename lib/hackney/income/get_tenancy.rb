module Hackney
  module Income
    class GetTenancy
      def initialize(gateway:)
        @gateway = gateway
      end

      def execute(tenancy_ref:)
        @gateway.get_tenancy(
          tenancy_ref: tenancy_ref
        )
      end
    end
  end
end
