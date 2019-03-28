module Hackney
  module Income
    module Jobs
      class SendLetterToGovNotifyJob < ApplicationJob
        HACKNEY_BUCKET_DOCS = Rails.application.config_for('cloud_storage')['bucket_docs']

        def perform(document_id:)
          p '----------'
          p 'runninn send'
          p '----------'
          document = Hackney::Cloud::Document.find(document_id)

          letter_pdf = pdf_file_from_s3(document.filename)
          metadata = get_metadata(document)

          thing = income_use_case_factory.send_precompiled_letter.execute(
            user_id: metadata[:user_id],
            payment_ref: metadata[:payment_ref],
            unique_reference: document.uuid,
            letter_pdf: letter_pdf
          )
          pp thing
        end

        private

        def pdf_file_from_s3(filename)
          tempfile =
            Rails.configuration
                 .cloud_adapter
                 .download(bucket_name: HACKNEY_BUCKET_DOCS, filename: filename)
          tempfile.is_a?(Tempfile || File) ? tempfile : raise('Unsupported file format')
        end

        def get_metadata(document)
          JSON.parse(document.metadata).symbolize_keys
        end
      end
    end
  end
end
