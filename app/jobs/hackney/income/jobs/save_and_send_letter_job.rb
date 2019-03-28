module Hackney
  module Income
    module Jobs
      class SaveAndSendLetterJob < ApplicationJob
        UPLOADED_CLOUD_STATUS = :uploaded
        queue_as :cloud_storage

        after_perform do
          Rails.logger.info 'after_perform enqueuing send letter to gov notify'
          Hackney::Income::Jobs::SendLetterToGovNotifyJob.perform_now(document_id: @document_id)
        end

        def perform(bucket_name:, filename:, content:, document_id:)
          @document_id = document_id
          response = cloud_provider.upload(bucket_name: bucket_name,
                                           content: content,
                                           filename: filename)

          document(document_id).update!(url: response[:url], status: UPLOADED_CLOUD_STATUS)
        end

        def cloud_provider
          Rails.configuration.cloud_adapter
        end

        private

        def document(document_id)
          Hackney::Cloud::Document.find(document_id)
        end
      end
    end
  end
end
