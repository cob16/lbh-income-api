module Hackney
  module Income
    class SqlTenancyCaseGateway
      GatewayModel = Hackney::Income::Models::CasePriority

      # TODO: rename from tenancies
      def persist(tenancies:)
        tenancies.each do |tenancy|
          GatewayModel.find_or_create_by!(tenancy_ref: tenancy.tenancy_ref)
        end
      end

      def assign_user(tenancy_ref:, user_id:)
        tenancy = GatewayModel.find_by(tenancy_ref: tenancy_ref)
        raise "Unable to assign user #{user_id} to tenancy #{tenancy_ref} - tenancy not found." if tenancy.nil?
        tenancy.update!(assigned_user_id: user_id)
      end

      def assigned_tenancies(assignee_id:)
        GatewayModel
          .where(assigned_user_id: assignee_id)
          .map { |t| { tenancy_ref: t.tenancy_ref } }
      end

      def assign_to_next_available_user(tenancy:)
        return nil unless PRIORITY_BANDS.include?(tenancy.priority_band)

        tenancy.assigned_user = next_available_user_for(band: tenancy.priority_band)
        tenancy.save
        tenancy.assigned_user_id
      end

      def find(tenancy_ref:)
        tenancy = GatewayModel.find_by(tenancy_ref: tenancy_ref)
        Rails.logger.error("Failed to retrieve tenancy with tenancy_ref: '#{tenancy_ref}' ") if tenancy.nil?
        tenancy
      end

      class TenancyNotFoundError < StandardError; end

      private

      def next_available_user_for(band:)
        counts = Hackney::Income::Models::User.with_tenancy_counts(of_priority_band: band)

        return Hackney::Income::Models::User.where(role: :credit_controller).first if counts.empty?

        Hackney::Income::Models::User.find_by(id: counts.min_by { |r| r[:count] }[:id])
      end

      PRIORITY_BANDS = %w[red amber green].freeze
    end
  end
end
