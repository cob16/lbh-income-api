module Hackney
  module Income
    class ProcessLetter
      def initialize(pdf_generator:, cloud_storage:)
        @pdf_generator = pdf_generator
        @cloud_storage = cloud_storage
      end

      def execute(uuid:, user_id:)
        cached_letter = Rails.cache.read(uuid)

        html = cached_letter[:preview]

        pdf_obj = @pdf_generator.execute(html)

        file_obj = pdf_obj.to_file("tmp/#{uuid}.pdf")

        File.delete("tmp/#{uuid}.pdf")
        Rails.cache.delete(uuid)

        @cloud_storage.save(file: file_obj, uuid: uuid, metadata: {
          user_id: user_id,
          payment_ref: cached_letter[:case][:payment_ref],
          template: cached_letter[:template]
        })
      end
    end
  end
end
