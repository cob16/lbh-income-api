module Hackney
  module Income
    class SqlTenancyCaseGateway
      def persist(tenancies:)
        tenancies.each do |tenancy|
          Hackney::Income::Models::Tenancy.find_or_create_by!(tenancy_ref: tenancy.tenancy_ref)
        end
      end

      def assign_user(tenancy_ref:, user_id:)
        tenancy = Hackney::Income::Models::Tenancy.find_by(tenancy_ref: tenancy_ref)
        tenancy.update!(assigned_user_id: user_id)
      end

      def assigned_tenancies(assignee_id:)
        Hackney::Income::Models::Tenancy
          .where(assigned_user_id: assignee_id)
          .map { |t| { tenancy_ref: t.tenancy_ref } }
      end

      def assign_to_next_available_user(tenancy:)
        return nil if !['red', 'amber', 'green'].include?(tenancy.priority_band)

        tenancy.assigned_user = next_available_user_for(band: tenancy.priority_band) || Hackney::Income::Models::User.all.first
        tenancy.save
        tenancy.assigned_user_id
      end

      private

      def next_available_user_for(band:)
        Hackney::Income::Models::User
          .left_joins(:tenancies)
          .group('users.id')
          .where('tenancies.priority_band = ?', band)
          .order('COUNT(tenancies.id) ASC')
          .first
      end
    end
  end
end
