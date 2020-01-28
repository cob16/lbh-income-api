module Hackney
  module Income
    class ScheduleSendSMS
      def initialize(matching_criteria_gateway:, background_job_gateway:)
        @matching_criteria_gateway = matching_criteria_gateway
        @background_job_gateway = background_job_gateway
      end

      def execute
        return unless env_allowed_to_send_automated_sms?

        tenancies_list = @matching_criteria_gateway.send_sms_messages
        Rails.logger.info("About to schedule #{tenancies_list.length} green in arrears msg jobs")
        tenancies_list.each do |tenancy|
          @background_job_gateway.schedule_send_sms_msg(case_id: tenancy.case_id)
        end
      end

      private

      def env_allowed_to_send_automated_sms?
        App::Application.feature_toggle('AUTOMATE_INCOME_COLLECTION_SMS')
      end
    end
  end
end
