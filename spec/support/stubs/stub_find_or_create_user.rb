module Hackney
  module Rent
    class StubFindOrCreateUser
      def initialize(users_gateway:); end

      def execute(provider_uid:, provider:, name:, email:, first_name:, last_name:, provider_permissions:); end
    end
  end
end
