module Hackney
  module Notification
    class RequestPrecompiledLetterState < BaseManualGateway
      def execute(message_id:)
        response =
          notification_gateway.precompiled_letter_state(
            message_id: message_id
          )

        update_document(message_id: message_id, status: response[:status])
        response
      end

      def update_document(message_id:, status:)
        store = Hackney::Cloud::Document
        doc = store.find_by!(ext_message_id: message_id)
        Rails.logger.info "Document ext_message_id #{message_id} found with status #{status}"
        doc.status = status
        doc.save!

        message = "Document has been set to #{status} - id: #{doc.id}, uuid: #{doc.uuid}"
        Rails.logger.info message

        evt = Raven::Event.new(message: message)
        Raven.send_event(evt) if doc.failed?
      end
    end
  end
end
