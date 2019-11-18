module Hackney
  module Notification
    class AddEntryToActionDiary
      def initialize(add_action_diary_usecase:, leasehold_gateway:)
        self.add_action_diary_usecase = add_action_diary_usecase
        self.leasehold_gateway = leasehold_gateway
      end

      def execute(user_id: nil, payment_ref: nil, template_id:)
        tenancy_ref = leasehold_gateway.get_tenancy_ref(payment_ref: payment_ref).dig(:tenancy_ref)

        ad_code = action_code(template_id: template_id)
        Rails.logger.info "writing action diary code #{ad_code} from template_id: #{template_id} 
                           for Letter '#{unique_reference}'"

        Hackney::Income::Jobs::AddActionDiaryEntryJob.perform_later(tenancy_ref: tenancy_ref, action_code: ad_code, comment: "Letter '#{unique_reference}' from '#{template_id}' letter was sent access it 
                    by visiting documents?payment_ref=#{payment_ref}")
      end

      private

      def action_code(template_id:)
        const_from_template_id = template_id.to_s.split(' ').join('_').upcase
        "Hackney::Tenancy::ActionCodes::#{const_from_template_id}".constantize
      end

      attr_reader :notification_gateway, :add_action_diary_usecase, :document_store, :leasehold_gateway
    end
  end
end
