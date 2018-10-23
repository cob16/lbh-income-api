module Hackney
  module Income
    class SqlPauseTenancyGateway
      def set_paused_until(tenancy_ref:, until_date:)
        tenancy = Hackney::Income::Models::Tenancy.find_by(tenancy_ref: tenancy_ref)
        raise "Unable to pause tenancy: #{tenancy_ref} - tenancy not found." if tenancy.nil?
        begin
          date = DateTime.parse(until_date)
        rescue ArgumentError
          raise "Unable to pause tenancy: #{tenancy_ref} until #{until_date} - invalid pause date."
        end
        tenancy.update!(is_paused_until: date)
      end
    end
  end
end
