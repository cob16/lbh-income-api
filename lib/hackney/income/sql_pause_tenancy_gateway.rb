module Hackney
  module Income
    class SqlPauseTenancyGateway
      def set_paused_until(tenancy_ref:, until_date:)
        tenancy = Hackney::Income::Models::Tenancy.find_by(tenancy_ref: tenancy_ref)
        raise "Unable to pause tenancy: #{tenancy_ref} - tenancy not found." if tenancy.nil?
        tenancy.update!(is_paused_until: DateTime.parse(until_date))
      end
    end
  end
end
