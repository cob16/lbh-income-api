module Hackney
  module Notification
    class SendAutomatedMessageToTenancy
      def initialize(automated_sms_usecase:, automated_email_usecase:, contacts_gateway:)
        @automated_sms_usecase = automated_sms_usecase
        @automated_email_usecase = automated_email_usecase
        @contacts_gateway = contacts_gateway
      end

      def execute(tenancy_ref:, sms_template_id:, email_template_id:, batch_id:, variables:)
        contacts = @contacts_gateway.get_responsible_contacts(tenancy_ref: tenancy_ref)

        numbers = contacts.map(&:phone_numbers).flatten.uniq.compact

        emails = contacts.map(&:email).flatten.uniq.compact

        emails.each do |email|
          @automated_email_usecase.execute(
            tenancy_ref: tenancy_ref,
            recipient: email,
            template_id: email_template_id,
            reference: batch_id,
            variables: variables
          )
        end

        numbers.each do |number|
          @automated_sms_usecase.execute(
            tenancy_ref: tenancy_ref,
            template_id: sms_template_id,
            phone_number: number,
            reference: batch_id,
            variables: variables
          )
        end
      end
    end
  end
end
