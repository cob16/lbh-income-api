module Hackney
  module Income
    module Jobs
      class SendIncomeCollectionLetterToGovNotifyJob < ApplicationJob
        HACKNEY_BUCKET_DOCS = Rails.application.config_for('cloud_storage')['bucket_docs']

        def perform(document_id:)
          Rails.logger.info "JOB: Performing SendLetterToGovNotifyJob on document_id: #{document_id}"

          document = Hackney::Cloud::Document.find(document_id)

          letter_pdf = pdf_file_from_s3(document.filename)

          letter_response =
            income_use_case_factory.send_precompiled_letter_to_gov_notify.execute(
              unique_reference: document.uuid,
              letter_pdf: letter_pdf
            )

          document.ext_message_id = letter_response.message_id
          document.save!
        end

        private

        def pdf_file_from_s3(filename)
          tempfile =
            Rails.configuration
                 .cloud_adapter
                 .download(bucket_name: HACKNEY_BUCKET_DOCS, filename: filename)
          tempfile.is_a?(Tempfile || File) ? tempfile : raise('Unsupported file format')
        end
      end
    end
  end
end
