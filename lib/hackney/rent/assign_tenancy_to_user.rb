module Hackney
  module Rent
    # TODO: rework to assign users to cases
    class AssignTenancyToUser
      def initialize(user_assignment_gateway:)
        @user_assignment_gateway = user_assignment_gateway
      end

      def assign(tenancy:)
        return tenancy.assigned_user_id unless tenancy.assigned_user.nil?

        @user_assignment_gateway.assign_to_next_available_user(tenancy: tenancy)
      end
    end
  end
end
