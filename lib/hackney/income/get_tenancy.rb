module Hackney
  module Income
    class GetTenancy
      def initialize(gateway:)
        @gateway = gateway
      end

      def execute(tenancy_ref:)
        @gateway.find(
          tenancy_ref: tenancy_ref
        )
      end
    end
  end
end
