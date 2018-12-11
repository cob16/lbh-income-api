module Hackney
  module Income
    module Jobs
      class SendGreenInArrearsMsgJob < ApplicationJob
        queue_as :message_jobs

        def perform(tenancy_ref:, balance:)
          Rails.logger.info("Starting SendGreenInArrearsMsgJob to tenancy_ref #{tenancy_ref}")
          income_use_case_factory.send_automated_message_to_tenancy.execute(
            tenancy_ref: tenancy_ref,
            sms_template_id: green_in_arrears_sms_template_id,
            email_template_id: green_in_arrears_email_template_id,
            batch_id: "SendGreenInArrearsMsgJob-#{tenancy_ref}-#{SecureRandom.uuid}",
            variables: {
              balance: balance
            }
          )
          Rails.logger.info("Finished SendGreenInArrearsMsgJob for tenancy_ref #{tenancy_ref}")
        end

        private

        def green_in_arrears_sms_template_id
          Rails.configuration.x.green_in_arrears.sms_template_id
        end

        def green_in_arrears_email_template_id
          Rails.configuration.x.green_in_arrears.email_template_id
        end
      end
    end
  end
end
