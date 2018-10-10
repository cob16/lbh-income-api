module Hackney
  module Income
    class SetTenancyPausedStatus
      def initialize(gateway:)
        @gateway = gateway
      end

      def execute(tenancy_ref:, status:)
        @gateway.set_paused_status(tenancy_ref: tenancy_ref, status: status)
      end
    end
  end
end
