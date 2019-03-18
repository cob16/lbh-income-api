module Hackney
  module Income
    class BackgroundJobGateway
      def schedule_case_priority_sync(tenancy_ref:)
        Hackney::Rent::Jobs::SyncCasePriorityJob.perform_later(tenancy_ref: tenancy_ref)
      end

      def schedule_send_green_in_arrears_msg(case_id:)
        Hackney::Rent::Jobs::SendGreenInArrearsMsgJob.perform_later(case_id: case_id)
      end

      def add_action_diary_entry(tenancy_ref:, action_code:, comment:)
        Hackney::Rent::Jobs::AddActionDiaryEntryJob.perform_later(tenancy_ref: tenancy_ref, action_code: action_code, comment: comment)
      end
    end
  end
end
