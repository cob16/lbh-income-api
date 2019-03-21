module Hackney
  module Income
    module Jobs
      class SendLetterToGovNotifyJob < ApplicationJob
        def perform(document_id:)

          doc = Hackney::Cloud::Document.find(document_id)
          unique_reference = doc.uuid
          letter_pdf = pdf_file_from_s3
          income_use_case_factory.send_precompiled_letter.execute(user_id: nil, payment_ref: nil, unique_reference: unique_reference, letter_pdf: letter_pdf)
        end

        private
        def pdf_file_from_s3
          # FIXME:
          # FIXME:
          # FIXME:
          raise 'implement me'
        end
      end
    end
  end
end
