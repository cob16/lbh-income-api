module Hackney
  module Rent
    class GetTenancyPause
      def initialize(gateway:)
        @gateway = gateway
      end

      def execute(tenancy_ref:)
        @gateway.get_tenancy_pause(
          tenancy_ref: tenancy_ref
        )
      end
    end
  end
end
