module UseCases
  class SaveLetterToCloud
    def initialize(cloud_gateway)
      @cloud_gateway = cloud_gateway
    end

    # we'd like to change binary_letter_content to something sensible, but we're
    # keeping the same interface for the cloud gateway at the moment
    def execute(uuid:, bucket_name:, pdf:)
      raise ArgumentError unless uuid.present?
      raise ArgumentError unless bucket_name.present?
      raise ArgumentError unless pdf.present?

      @cloud_gateway.upload(
        binary_letter_content: pdf,
        bucket_name: bucket_name,
        filename: "#{uuid}.pdf"
      )
    end
  end
end
