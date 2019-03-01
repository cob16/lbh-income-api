module Hackney
  module ServiceCharge
    class GetCaseByRef
      def initialize(service_charge_gateway:)
        @service_charge_gateway = service_charge_gateway
      end

      def execute(payment_ref:)
        @service_charge_gateway.fake_get_cases_by_refs([payment_ref])
      end
    end
  end
end
