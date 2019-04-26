module Hackney
  module Tenancy
    module ActionCodes
      AUTOMATED_SMS_ACTION_CODE = 'GAT'.freeze
      AUTOMATED_EMAIL_ACTION_CODE = 'GAE'.freeze

      # TODO: remove these, previous behaviour defaulted to Green for everything
      MANUAL_SMS_ACTION_CODE = 'GMS'.freeze
      MANUAL_EMAIL_ACTION_CODE = 'GME'.freeze

      MANUAL_GREEN_SMS_ACTION_CODE = 'GMS'.freeze
      MANUAL_GREEN_EMAIL_ACTION_CODE = 'GME'.freeze
      MANUAL_AMBER_SMS_ACTION_CODE = 'AMS'.freeze
    end
  end
end
