require 'rails_helper'

describe 'Send SMS Rule', type: :feature do
  send_sms_condition_matrix = [
    {
      outcome: :send_first_SMS,
      nosps_in_last_year: 0,
      nosp_expiry_date: '',
      weekly_rent: 10,
      balance: 5,
      is_paused_until: '',
      last_communication_date: 2.weeks.ago.to_date,
      last_communication_action: nil,
      eviction_date: '',
      courtdate: nil
    },
    # payment agreement test
    {
      outcome: :no_action,
      nosps_in_last_year: 0,
      nosp_expiry_date: '',
      weekly_rent: 10,
      balance: 6,
      is_paused_until: '',
      most_recent_agreement: { start_date: 1.week.ago },
      last_communication_date: 2.weeks.ago.to_date,
      last_communication_action: '',
      eviction_date: '',
      courtdate: nil
    },
    # balance test
    {
      outcome: :no_action,
      nosps_in_last_year: 0,
      nosp_expiry_date: '',
      weekly_rent: 10,
      balance: 4.0,
      is_paused_until: '',
      last_communication_date: 2.weeks.ago.to_date,
      last_communication_action: Hackney::Tenancy::ActionCodes::MANUAL_SMS_ACTION_CODE,
      eviction_date: '',
      courtdate: nil
    }
  ]

  it_behaves_like 'TenancyClassification', send_sms_condition_matrix
end
