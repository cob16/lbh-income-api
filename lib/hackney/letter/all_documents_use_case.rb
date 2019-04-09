module Hackney
  module Letter
    class AllDocumentsUseCase
      def initialize(cloud_storage:)
        @cloud_storage = cloud_storage
      end

      def execute
        @cloud_storage.all_documents
      end
    end
  end
end
