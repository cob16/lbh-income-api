module Hackney
  module Income
    class ProcessLetter
      def initialize(pdf_generator:, cloud_storage:)
        @pdf_generator = pdf_generator
        @cloud_storage = cloud_storage
      end

      def execute(uuid:, user_id:)
        html = Rails.cache.read(uuid)
        pdf_obj = @pdf_generator.execute(html)

        @cloud_storage.save(pdf: pdf_obj, metadata: { user_id: user_id })
      end
    end
  end
end
