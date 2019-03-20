module Hackney
  module Cloud
    module Jobs
      class SaveToCloudJob < ApplicationJob
        UPLOADED_CLOUD_STATUS = :uploaded

        queue_as :cloud_storage

        def perform(bucket_name:, filename:, content:, document_id:)
          url = cloud_provider.upload(bucket_name: bucket_name,
                                      content: content,
                                      new_filename: filename)

          document(document_id).update!(url: url, status: UPLOADED_CLOUD_STATUS)
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
