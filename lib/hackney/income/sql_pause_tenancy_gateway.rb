module Hackney
  module Income
    class SqlPauseTenancyGateway
      def set_paused_status(tenancy_ref:, status:)
        tenancy = Hackney::Income::Models::Tenancy.find_by(tenancy_ref: tenancy_ref)
        raise "Unable to pause tenancy: #{tenancy_ref} - tenancy not found." if tenancy.nil?
        tenancy.update!(is_paused: status)
      end
    end
  end
end
