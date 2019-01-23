module Hackney
  module Income
    # TODO: RENAME from ScheduleSyncCases to descriptive schedule and delete
    class ScheduleSyncCases
      def initialize(uh_tenancies_gateway:, background_job_gateway:)
        @uh_tenancies_gateway = uh_tenancies_gateway
        @background_job_gateway = background_job_gateway
        @case_priority_gateway = Hackney::Income::Models::CasePriority
      end

      def execute
        Rails.logger.info('preparing to sync tenancies_in_arrears ')

        # TODO: RENAME tenancies_in_arrears to tenancy_refs_in_arrears
        tenancy_refs = @uh_tenancies_gateway.tenancies_in_arrears
        found_case_priorities = @case_priority_gateway.all

        Rails.logger.info("About to schedule #{tenancy_refs.length} case priority sync jobs")
        tenancy_refs.each do |tenancy_ref|
          @background_job_gateway.schedule_case_priority_sync(tenancy_ref: tenancy_ref)
        end

        delete_case_priorities_not_syncable(case_priorities: found_case_priorities, tenancy_refs: tenancy_refs)
      end

      def delete_case_priorities_not_syncable(case_priorities:, tenancy_refs:)
        Rails.logger.info('Deleting case_priorities that are not to be synced')
        case_refs_not_synced = case_priorities.pluck(:tenancy_ref) - tenancy_refs
        @case_priority_gateway.where(tenancy_ref: case_refs_not_synced).destroy_all if case_refs_not_synced.any?
      end
    end
  end
end
