module Hackney
  module Letter
    class DownloadUseCase
      def initialize(cloud_storage)
        @cloud_storage = cloud_storage
      end

      def execute(uuid:)
        @cloud_storage.read_document(uuid)
      end
    end
  end
end
