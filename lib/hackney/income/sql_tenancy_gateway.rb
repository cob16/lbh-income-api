require 'time'
require 'active_record/errors'

module Hackney
  module Income
    class SqlTenancyGateway
      GatewayModel = Hackney::Income::Models::CasePriority

      def get_tenancy(tenancy_ref:)
        tenancy = GatewayModel.find_by(tenancy_ref: tenancy_ref)
        if tenancy.nil?
          Rails.logger.error("Failed to retrieve tenancy with tenancy_ref: '#{tenancy_ref}' ")
          raise TenancyNotFoundError, "Unable to get tenancy: #{tenancy_ref} - tenancy not found."
        end
        tenancy
      end

      class TenancyNotFoundError < StandardError; end
    end
  end
end
