module Hackney
  module Income
    class AssignTenancyToUser
      def initialize(user_assignment_gateway:)
        @user_assignment_gateway = user_assignment_gateway
      end

      def assign(tenancy:)
        return tenancy.assigned_user_id if tenancy.assigned_user != nil

        @user_assignment_gateway.assign_to_next_available_user(tenancy: tenancy)
      end
    end
  end
end
