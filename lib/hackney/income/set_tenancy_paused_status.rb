module Hackney
  module Income
    class SetTenancyPausedStatus
      def initialize(gateway:)
        @gateway = gateway
      end

      def execute(tenancy_ref:, until_date:)
        @gateway.set_paused_until(tenancy_ref: tenancy_ref, until_date: until_date)
      end
    end
  end
end
