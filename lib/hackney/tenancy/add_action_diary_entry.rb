require 'httparty'

module Hackney
  module Tenancy
    class AddActionDiaryEntry
      def initialize(action_diary_gateway:, users_gateway:)
        @action_diary_gateway = action_diary_gateway
        @users_gateway = users_gateway
      end

      def execute(tenancy_ref:, action_code:, comment:, user_id: nil, date: nil)
        # if user_id look up
        username = user_id.nil? ? nil : @users_gateway.find_user(id: user_id)&.name
        date = date.nil? ? DateTime.now : date

        raise ArgumentError, 'user_id supplied does not exist' if !user_id.nil? && username.nil?

        Rails.logger.info("Adding action diary comment to #{tenancy_ref} with username '#{username}'")
        @action_diary_gateway.create_entry(tenancy_ref: tenancy_ref, action_code: action_code, comment: comment, username: username, date: date)
      end
    end
  end
end
