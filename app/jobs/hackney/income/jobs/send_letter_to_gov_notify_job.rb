module Hackney
  module Income
    module Jobs
      class SendLetterToGovNotifyJob < ApplicationJob
        HACKNEY_BUCKET_DOCS = Rails.application.config_for('cloud_storage')['bucket_docs']

        def perform(document_id:)

          document = Hackney::Cloud::Document.find(document_id)

          unique_reference = document.uuid

          document_metadata = get_metadata(document)

          letter_pdf = pdf_file_from_s3(document.filename)

          income_use_case_factory.send_precompiled_letter.execute(
            user_id: document_metadata[:user_id],
            payment_ref: document_metadata[:payment_ref],
            unique_reference: unique_reference,
            letter_pdf: letter_pdf
          )
        end

        private

        def pdf_file_from_s3(filename)
          # FIXME:
          # FIXME:
          # FIXME:
          # raise 'implement me'

          Rails.configuration.cloud_adapter.download(HACKNEY_BUCKET_DOCS, filename)
        end

        def get_metadata(document)
          JSON.parse(document.metadata).symbolize_keys
        end
      end
    end
  end
end

