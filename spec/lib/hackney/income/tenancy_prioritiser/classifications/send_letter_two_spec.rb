require 'rails_helper'

describe 'Send Letter Two Rule', type: :feature do
  letter_1_in_arrears_sent_code = 'IC1'

  send_letter_two_condition_matrix = [
    {
      outcome: :send_letter_two,
      nosps_in_last_year: 0,
      nosp_expiry_date: '',
      weekly_rent: 5,
      balance: 15.0,
      is_paused_until: '',
      active_agreement: false,
      last_communication_date: 2.weeks.ago.to_date,
      last_communication_action: letter_1_in_arrears_sent_code,
      eviction_date: '',
      courtdate: ''
    },
    # balance test
    {
      outcome: :no_action,
      nosps_in_last_year: 0,
      nosp_expiry_date: '',
      weekly_rent: 5,
      balance: 14.0,
      is_paused_until: '',
      active_agreement: false,
      last_communication_date: 2.weeks.ago.to_date,
      last_communication_action: letter_1_in_arrears_sent_code,
      eviction_date: '',
      courtdate: ''
    },
    # nosps in last year test
    {
      outcome: :no_action,
      nosps_in_last_year: 1,
      nosp_expiry_date: '',
      weekly_rent: 5,
      balance: 15.0,
      is_paused_until: '',
      active_agreement: false,
      last_communication_date: 2.weeks.ago.to_date,
      last_communication_action: letter_1_in_arrears_sent_code,
      eviction_date: '',
      courtdate: ''
    },
    # last communication date tests
    {
      outcome: :no_action,
      nosps_in_last_year: 0,
      nosp_expiry_date: '',
      weekly_rent: 5,
      balance: 15.0,
      is_paused_until: '',
      active_agreement: false,
      last_communication_date: 5.days.ago.to_date,
      last_communication_action: letter_1_in_arrears_sent_code,
      eviction_date: '',
      courtdate: ''
    },
    {
      outcome: :no_action,
      nosps_in_last_year: 0,
      nosp_expiry_date: '',
      weekly_rent: 5,
      balance: 15.0,
      is_paused_until: '',
      active_agreement: false,
      last_communication_date: 3.months.from_now.to_date,
      last_communication_action: letter_1_in_arrears_sent_code,
      eviction_date: '',
      courtdate: ''
    },
    # last communication action test
    {
      outcome: :no_action,
      nosps_in_last_year: 0,
      nosp_expiry_date: '',
      weekly_rent: 5,
      balance: 15.0,
      is_paused_until: '',
      active_agreement: false,
      last_communication_date: 2.weeks.ago.to_date,
      last_communication_action: 'WRONG',
      eviction_date: '',
      courtdate: ''
    },
    {
      outcome: :send_letter_two,
      nosps_in_last_year: 0,
      nosp_expiry_date: '',
      weekly_rent: 5,
      balance: 15.0,
      is_paused_until: '',
      active_agreement: false,
      last_communication_date: 2.weeks.ago.to_date,
      last_communication_action: letter_1_in_arrears_sent_code,
      eviction_date: '',
      courtdate: ''
    },
    # eviction date test
    {
      outcome: :no_action,
      nosps_in_last_year: 0,
      nosp_expiry_date: '',
      weekly_rent: 5,
      balance: 15.0,
      is_paused_until: '',
      active_agreement: false,
      last_communication_date: 2.weeks.ago.to_date,
      last_communication_action: letter_1_in_arrears_sent_code,
      eviction_date: 5.days.from_now.to_date,
      courtdate: ''
    }
  ]

  it_behaves_like 'TenancyClassification', send_letter_two_condition_matrix
end