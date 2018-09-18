module Hackney
  module Income
    class DangerousSyncCases
      def initialize(prioritisation_gateway:, uh_tenancies_gateway:, stored_tenancies_gateway:, assign_tenancy_to_user:)
        @prioritisation_gateway = prioritisation_gateway
        @uh_tenancies_gateway = uh_tenancies_gateway
        @stored_tenancies_gateway = stored_tenancies_gateway
        @assign_tenancy_to_user = assign_tenancy_to_user
      end

      def execute
        tenancy_refs = @uh_tenancies_gateway.tenancies_in_arrears
        tenancy_refs.each do |tenancy_ref|
          priorities = @prioritisation_gateway.priorities_for_tenancy(tenancy_ref)
          tenancy = @stored_tenancies_gateway.store_tenancy(
            tenancy_ref: tenancy_ref,
            priority_band: priorities.fetch(:priority_band),
            priority_score: priorities.fetch(:priority_score),
            criteria: priorities.fetch(:criteria),
            weightings: priorities.fetch(:weightings)
          )
          @assign_tenancy_to_user.assign(tenancy: tenancy)
        end
      end
    end
  end
end
