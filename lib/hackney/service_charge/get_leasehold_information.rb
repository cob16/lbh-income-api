module Hackney
  module ServiceCharge
    class GetLeaseholdInformation
      def initialize(service_charge_gateway:)
        @service_charge_gateway = service_charge_gateway
      end

      def execute(payment_ref:)
        @service_charge_gateway.get_leasehold_information(payment_ref)
      end
    end
  end
end
