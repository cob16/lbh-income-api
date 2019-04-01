module Hackney
  module Cloud
    class Storage
      HACKNEY_BUCKET_DOCS = Rails.application.config_for('cloud_storage')['bucket_docs']
      UPLOADING_CLOUD_STATUS = :uploading

      def initialize(storage_adapter, document_model)
        @storage_adapter = storage_adapter
        @document_model = document_model
      end

      def save(letter_html:, uuid:, filename:, metadata:)
        extension = File.extname(filename)

        new_doc = document_model.create(
          filename: filename,
          uuid: uuid,
          extension: extension,
          mime_type: Rack::Mime.mime_type(extension),
          status: UPLOADING_CLOUD_STATUS,
          metadata: metadata.to_json
        )

        if new_doc.errors.empty?
          Hackney::Income::Jobs::SaveAndSendLetterJob.perform_later(
            bucket_name: HACKNEY_BUCKET_DOCS,
            letter_html: letter_html,
            filename: filename,
            document_id: new_doc.id
          )
        end

        { errors: new_doc.errors.full_messages }
      end

      def read_document(id)
        doc = document_model.find_by(id: id)

        raise 'File does not exist!' if doc.nil?

        response = @storage_adapter.download(HACKNEY_BUCKET_DOCS, doc.uuid + doc.extension)

        { content: response }
      end

      def upload(bucket_name, content, filename)
        if content.is_a? StringIO
          sio = Tempfile.open(filename, 'tmp/')
          sio.binmode

          sio.write content.read
          sio.rewind
          content = sio
        end

        @storage_adapter.upload(bucket_name: bucket_name, content: content, filename: filename)
      end

      private

      attr_reader :document_model
    end
  end
end
