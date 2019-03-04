module Hackney
  module ServiceCharge
    class UseCaseFactory
      def get_case_by_ref
        Hackney::ServiceCharge::GetCaseByRef.new(
          service_charge_gateway: service_charge_gateway
        )
      end

      private

      def service_charge_gateway
        Hackney::ServiceCharge::Gateway::ServiceChargeGateway.new(
          host: 'TEMPLATE_DIRECTORY_PATH',
          api_key: 'TEMPLATE_DIRECTORY_PATH'
        )
      end
    end
  end
end
