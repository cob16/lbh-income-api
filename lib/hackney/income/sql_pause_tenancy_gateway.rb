require 'active_record/errors'
module Hackney
  module Income
    class SqlPauseTenancyGateway
      def set_paused_until(tenancy_ref:, until_date:)
        tenancy = Hackney::Income::Models::Tenancy.find_by(tenancy_ref: tenancy_ref)
        raise "Unable to pause tenancy: #{tenancy_ref} - tenancy not found." if tenancy.nil?
        date = DateTime.parse(until_date)
        tenancy.update!(is_paused_until: date)
      rescue ArgumentError
        raise "Unable to pause tenancy: #{tenancy_ref} until #{until_date} - invalid pause date."
      rescue ActiveRecord::RecordNotSaved
        raise "Unable to pause tenancy: #{tenancy_ref} - something went wrong while updating."
      end
    end
  end
end
