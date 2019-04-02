module Hackney
  module Notification
    class RequestPrecompiledLetterState < BaseManualGateway
      def execute(unique_reference:)
        response =
          notification_gateway.precompiled_letter_state(
            unique_reference: unique_reference
          )

        update_document(unique_reference: unique_reference, status: response[:status])
        response
      end

      def update_document(unique_reference:, status:)
        # document_store = Hackney::Cloud::Document
        doc = document_store.find_by!(uuid: unique_reference)
        doc.status = status
        doc.save!
      end
    end
  end
end
