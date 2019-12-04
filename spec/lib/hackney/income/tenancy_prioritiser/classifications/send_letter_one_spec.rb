require 'rails_helper'

describe 'Send Letter One Rule', type: :feature do
  send_letter_one_condition_matrix = [
    {
      outcome: :send_letter_one,
      nosps_in_last_year: 0,
      nosp_expiry_date: '',
      weekly_rent: 5,
      balance: 6.0,
      is_paused_until: '',
      active_agreement: false,
      last_communication_date: 2.weeks.ago.to_date,
      last_communication_action: Hackney::Tenancy::ActionCodes::AUTOMATED_SMS_ACTION_CODE,
      eviction_date: '',
      courtdate: ''
    },
    {
      outcome: :send_letter_one,
      nosps_in_last_year: 0,
      nosp_expiry_date: '',
      weekly_rent: 5,
      balance: 6.0,
      is_paused_until: '',
      active_agreement: false,
      last_communication_date: 2.weeks.ago.to_date,
      last_communication_action: Hackney::Tenancy::ActionCodes::MANUAL_SMS_ACTION_CODE,
      eviction_date: '',
      courtdate: ''
    },
    # active_agreement test
    {
      outcome: :no_action,
      nosps_in_last_year: 0,
      nosp_expiry_date: '',
      weekly_rent: 5,
      balance: 6.0,
      is_paused_until: '',
      active_agreement: true,
      last_communication_date: 2.weeks.ago.to_date,
      last_communication_action: Hackney::Tenancy::ActionCodes::MANUAL_SMS_ACTION_CODE,
      eviction_date: '',
      courtdate: ''
    },
    # balance test
    {
      outcome: :no_action,
      nosps_in_last_year: 0,
      nosp_expiry_date: '',
      weekly_rent: 5,
      balance: 4.0,
      is_paused_until: '',
      active_agreement: false,
      last_communication_date: 2.weeks.ago.to_date,
      last_communication_action: Hackney::Tenancy::ActionCodes::MANUAL_SMS_ACTION_CODE,
      eviction_date: '',
      courtdate: ''
    }
  ]

  it_behaves_like 'TenancyClassification', send_letter_one_condition_matrix
end
