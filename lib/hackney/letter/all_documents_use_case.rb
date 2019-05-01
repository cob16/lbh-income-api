module Hackney
  module Letter
    class AllDocumentsUseCase
      def initialize(cloud_storage:)
        @cloud_storage = cloud_storage
      end

      def execute(payment_ref: nil)
        @cloud_storage.all_documents(payment_ref: payment_ref)
                      .each do |doc|
          next unless doc.metadata
          metadata = JSON.parse(doc.metadata).deep_symbolize_keys
          if metadata[:user_id]
            metadata[:user_name] = user_name(metadata[:user_id])
            doc.metadata = metadata.to_json
          end
        end
      end

      private

      def user_name(user_id)
        user = Hackney::Income::Models::User.find_by(id: user_id)
        user ? user.name : nil
      end
    end
  end
end
