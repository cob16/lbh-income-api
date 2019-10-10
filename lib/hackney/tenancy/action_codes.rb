module Hackney
  module Tenancy
    module ActionCodes
      AUTOMATED_SMS_ACTION_CODE = 'GAT'.freeze
      AUTOMATED_EMAIL_ACTION_CODE = 'GAE'.freeze

      MANUAL_SMS_ACTION_CODE = 'GMS'.freeze
      MANUAL_EMAIL_ACTION_CODE = 'GME'.freeze

      MANUAL_GREEN_SMS_ACTION_CODE = 'GMS'.freeze
      MANUAL_AMBER_SMS_ACTION_CODE = 'AMS'.freeze

      # Codes for letters as follows:
      LETTER_1_IN_ARREARS_FH = 'LF1'.freeze
      LETTER_2_IN_ARREARS_FH = 'LF2'.freeze
      LETTER_1_IN_ARREARS_LH = 'LL1'.freeze
      LETTER_2_IN_ARREARS_LH = 'LL2'.freeze
      LETTER_1_IN_ARREARS_SO = 'LS1'.freeze
      LETTER_2_IN_ARREARS_SO = 'LS2'.freeze

      GREEN_SMS_SENT_AUTO = 'GAT'.freeze
      GREEN_SMS_SENT_MANUAL = 'GMS'.freeze

      LETTER_1_IN_ARREARS_AUTO = 'IC1'.freeze
      LETTER_1_IN_ARREARS_MANUAL ='IM1'.freeze

      LETTER_2_IN_ARREARS_AUTO = 'IC2'.freeze
      LETTER_2_IN_ARREARS_MANUAL ='IM2'.freeze

      PRE_NOSP_WARNING_LETTER_AUTO = 'IC3'.freeze
      PRE_NOSP_WARNING_LETTER_MANUAL ='IM3'.freeze
    end
  end
end
