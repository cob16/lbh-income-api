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
      last_communication_action: '',
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
      last_communication_action: '',
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
      last_communication_action: '',
      eviction_date: '',
      courtdate: ''
    },
    # last action was send letter two, falls back into send letter one and no action is carried out for  over 3 months
    {
      outcome: :send_letter_one,
      nosps_in_last_year: 0,
      nosp_expiry_date: '',
      weekly_rent: 5,
      balance: 6,
      is_paused_until: '',
      active_agreement: false,
      last_communication_date: 4.months.ago.to_date,
      last_communication_action: Hackney::Tenancy::ActionCodes::INCOME_COLLECTION_LETTER_2,
      eviction_date: '',
      courtdate: ''
    },
    {
      outcome: :no_action,
      nosps_in_last_year: 0,
      nosp_expiry_date: '',
      weekly_rent: 5,
      balance: 6,
      is_paused_until: '',
      active_agreement: false,
      last_communication_date: 2.months.ago.to_date,
      last_communication_action: Hackney::Tenancy::ActionCodes::INCOME_COLLECTION_LETTER_2,
      eviction_date: '',
      courtdate: ''
    }
  ]

  it_behaves_like 'TenancyClassification', send_letter_one_condition_matrix
end
