module Hackney
  module Income
    module Jobs
      class SendSMSJob < ApplicationJob
        attr_accessor :created_at
        EXPIRATION_DAYS = 5.days.freeze

        queue_as :message_jobs

        before_perform :check_expiration

        def initialize(*arguments)
          super
          self.created_at = Time.now
        end

        def perform(case_id:)
          return unless env_allowed_to_send_automated_sms?

          case_priority = Hackney::Income::Models::CasePriority.find_by!(case_id: case_id)
          case_ready_for_sms_automation = income_use_case_factory.case_ready_for_sms_automation

          return unless case_ready_for_sms_automation.execute(patch_code: case_priority.patch_code)

          Rails.logger.info("Starting SendSMSJob for case id #{case_priority.case_id}")
          income_use_case_factory.send_automated_message_to_tenancy.execute(
            tenancy_ref: case_priority.tenancy_ref,
            sms_template_id: green_in_arrears_sms_template_id,
            email_template_id: green_in_arrears_email_template_id,
            batch_id: "SendSMSJob-#{case_priority.tenancy_ref}-#{SecureRandom.uuid}",
            variables: {
              balance: case_priority.balance
            }
          )
          Rails.logger.info("Finished SendSMSJob for case id #{case_priority.case_id}")
        end

        private

        def green_in_arrears_sms_template_id
          Rails.configuration.x.green_in_arrears.sms_template_id
        end

        def green_in_arrears_email_template_id
          Rails.configuration.x.green_in_arrears.email_template_id
        end

        def check_expiration
          raise 'Error: Job expired!' if created_at <= Time.now - EXPIRATION_DAYS
        end

        def env_allowed_to_send_automated_sms?
          App::Application.feature_toggle('AUTOMATE_INCOME_COLLECTION_SMS')
        end
      end
    end
  end
end
