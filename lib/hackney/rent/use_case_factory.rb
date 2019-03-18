module Hackney
  module Rent
    class UseCaseFactory
      def view_my_cases
        Hackney::Income::ViewMyCases.new(
          tenancy_api_gateway: tenancy_api_gateway,
          stored_tenancies_gateway: stored_tenancies_gateway
        )
      end

      def schedule_sync_cases
        Hackney::Income::ScheduleSyncCases.new(
          uh_tenancies_gateway: uh_tenancies_gateway,
          background_job_gateway: background_job_gateway
        )
      end

      def schedule_green_in_arrears_message
        Hackney::Rent::ScheduleGreenInArrearsMessage.new(
          matching_criteria_gateway: sql_tenancies_matching_criteria_gateway,
          background_job_gateway: background_job_gateway
        )
      end

      def find_or_create_user
        Hackney::Income::FindOrCreateUser.new(users_gateway: users_gateway)
      end

      def add_action_diary
        Hackney::Tenancy::AddActionDiaryEntry.new(
          action_diary_gateway: action_diary_gateway,
          users_gateway: users_gateway
        )
      end

      def send_manual_sms
        Hackney::Notification::SendManualSms.new(
          notification_gateway: notifications_gateway,
          add_action_diary_usecase: add_action_diary
        )
      end

      def send_manual_email
        Hackney::Notification::SendManualEmail.new(
          notification_gateway: notifications_gateway,
          add_action_diary_usecase: add_action_diary
        )
      end

      def send_precompiled_letter
        Hackney::Rent::Notification::SendPrecompiledLetter.new(
          notification_gateway: notifications_gateway,
          add_action_diary_usecase: add_action_diary
        )
      end

      def send_automated_sms
        Hackney::Notification::SendAutomatedSms.new(
          notification_gateway: notifications_gateway,
          background_job_gateway: background_job_gateway
        )
      end

      def send_automated_email
        Hackney::Notification::SendAutomatedEmail.new(
          notification_gateway: notifications_gateway,
          background_job_gateway: background_job_gateway
        )
      end

      def send_automated_message_to_tenancy
        Hackney::Notification::SendAutomatedMessageToTenancy.new(
          automated_sms_usecase: send_automated_sms,
          automated_email_usecase: send_automated_email,
          contacts_gateway: contacts_gateway
        )
      end

      def get_templates
        Hackney::Notification::GetTemplates.new(
          notification_gateway: notifications_gateway
        )
      end

      def set_tenancy_paused_status
        Hackney::Income::SetTenancyPausedStatus.new(
          gateway: sql_pause_tenancy_gateway,
          add_action_diary_usecase: add_action_diary
        )
      end

      def get_tenancy_pause
        Hackney::Income::GetTenancyPause.new(
          gateway: sql_pause_tenancy_gateway
        )
      end

      def sync_case_priority
        ActiveSupport::Deprecation.warn(
          "SyncCasePriorityJob is deprecated - use external scheduler via 'rake rent:sync:enqueue'"
        )
        Hackney::Rent::SyncCasePriority.new(
          prioritisation_gateway: prioritisation_gateway,
          stored_tenancies_gateway: stored_tenancies_gateway,
          assign_tenancy_to_user: assign_tenancy_to_user
        )
      end

      def migrate_patch_to_lcw
        Hackney::Rent::MigratePatchToLcw.new(
          legal_cases_gateway: legal_cases_gateway,
          user_assignment_gateway: user_assignment_gateway
        )
      end

      def assign_tenancy_to_user
        Hackney::Rent::AssignTenancyToUser.new(user_assignment_gateway: user_assignment_gateway)
      end

      # intended to only be used for rake task please delete when no longer required
      def show_green_in_arrears
        Hackney::Rent::ShowTenanciesForCriteriaGreenInArrears.new(
          sql_tenancies_for_messages_gateway: sql_tenancies_matching_criteria_gateway
        )
      end

      private

      def notifications_gateway
        Hackney::Notification::GovNotifyGateway.new(
          sms_sender_id: Rails.configuration.x.gov_notify.sms_sender_id,
          api_key: Rails.configuration.x.gov_notify.api_key,
          send_live_communications: Rails.configuration.x.gov_notify.send_live,
          test_phone_number: Rails.configuration.x.gov_notify.test_phone_number,
          test_email_address: Rails.configuration.x.gov_notify.test_email_address
        )
      end

      def legal_cases_gateway
        Hackney::Rent::SqlLegalCasesGateway.new
      end

      def prioritisation_gateway
        Hackney::Rent::UniversalHousingPrioritisationGateway.new
      end

      def sql_pause_tenancy_gateway
        Hackney::Income::SqlPauseTenancyGateway.new
      end

      def stored_tenancies_gateway
        Hackney::Income::StoredTenanciesGateway.new
      end

      def users_gateway
        Hackney::Income::SqlUsersGateway.new
      end

      def user_assignment_gateway
        Hackney::Income::SqlTenancyCaseGateway.new
      end

      def uh_tenancies_gateway
        Hackney::Rent::UniversalHousingTenanciesGateway.new(
          restrict_patches: ENV.fetch('RESTRICT_PATCHES', false),
          patches: ENV.fetch('PERMITTED_PATCHES', '').split(',')
        )
      end

      def tenancy_api_gateway
        Hackney::Tenancy::Gateway::TenanciesGateway.new(
          host: ENV.fetch('TENANCY_API_HOST'),
          key: ENV.fetch('TENANCY_API_KEY')
        )
      end

      def contacts_gateway
        Hackney::Tenancy::Gateway::ContactsGateway.new(
          host: ENV.fetch('TENANCY_API_HOST'),
          api_key: ENV.fetch('TENANCY_API_KEY')
        )
      end

      def action_diary_gateway
        Hackney::Tenancy::Gateway::ActionDiaryGateway.new(
          host: ENV.fetch('TENANCY_API_HOST'),
          api_key: ENV.fetch('TENANCY_API_KEY')
        )
      end

      def sql_tenancies_matching_criteria_gateway
        Hackney::Rent::SqlTenanciesMatchingCriteriaGateway.new
      end

      def background_job_gateway
        Hackney::Income::BackgroundJobGateway.new
      end
    end
  end
end
