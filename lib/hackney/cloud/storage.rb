module Hackney
  module Cloud
    class Storage
      HACKNEY_BUCKET_DOCS = Rails.application.config_for('cloud_storage')['bucket_docs']
      UPLOADING_CLOUD_STATUS = :uploading

      def initialize(storage_adapter, document_model)
        @storage_adapter = storage_adapter
        @document_model = document_model
      end

      def save(file:, uuid:, metadata:)
        extension = File.extname(file)
        filename = File.basename(file)

        new_doc = document_model.create(
          filename: filename,
          uuid: uuid,
          extension: extension,
          mime_type: Rack::Mime.mime_type(extension),
          status: UPLOADING_CLOUD_STATUS,
          metadata: metadata.to_json
        )

        if new_doc.errors.empty?
          file.rewind
          Hackney::Cloud::Jobs::SaveToCloudJob.perform_later(
            bucket_name: HACKNEY_BUCKET_DOCS,
            content: file.read,
            filename: filename,
            document_id: new_doc.id
          )
        end

        { errors: new_doc.errors.full_messages }
      end

      def upload(bucket_name, content, filename)
        @storage_adapter.upload(bucket_name: bucket_name, content: content, filename: filename)
      end

      private

      attr_reader :document_model
    end
  end
end
