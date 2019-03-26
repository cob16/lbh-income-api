module Hackney
  module Cloud
    class StorageFake
      def initialize(storage_adapter, document_model)
        @storage_adapter = storage_adapter
        @document_model = document_model
        @content = ''

        @in_memory_storage = {}
      end

      def save(filename)
        uuid = SecureRandom.uuid
        @content = File.read(filename)
        @in_memory_storage = { content: @content, uuid: uuid }
        { uuid: uuid, errors: [] }
      end

      def read_document(_uuid)
        @in_memory_storage[:content]
      end

      private

      attr_reader :document_model
    end
  end
end
