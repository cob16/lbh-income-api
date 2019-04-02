module Hackney
  module Letter
    class DownloadUseCase
      def initialize(cloud_storage)
        @cloud_storage = cloud_storage
      end

      def execute(id:)
        @cloud_storage.read_document(id)
      end
    end
  end
end
