module Hackney
  module Income
    class SetTenancyPausedStatus
      def initialize(gateway:)
        @gateway = gateway
      end

      def execute(tenancy_ref:, until_date:, pause_reason:, pause_comment:)
        @gateway.set_paused_until(
          tenancy_ref: tenancy_ref,
          until_date: until_date,
          pause_reason: pause_reason,
          pause_comment: pause_comment
        )
      end
    end
  end
end
