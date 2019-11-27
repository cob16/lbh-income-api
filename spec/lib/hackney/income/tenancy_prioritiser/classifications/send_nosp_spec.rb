require 'rails_helper'
require_relative 'shared_example'

describe 'Send NOSP Rule', type: :feature do
  pre_nosp_warning_letter = 'IC3'.freeze

  send_nosp_condition_matrix = [
    {
      outcome: :no_action,
      nosps_in_last_year: 1,
      nosp_expiry_date: 8.months.from_now.to_date,
      weekly_rent: 5,
      balance: 25.0, # 5 * weekly_rent
      is_paused_until: nil,
      active_agreement: false,
      last_communication_date: 2.months.ago.to_date,
      last_communication_action: pre_nosp_warning_letter,
      eviction_date: nil
    },
    {
      outcome: :no_action,
      nosps_in_last_year: 0,
      nosp_expiry_date: 1.month.ago.to_date,
      weekly_rent: 5,
      balance: 10.0, # 2 * weekly_rent
      is_paused_until: nil,
      active_agreement: false,
      last_communication_date: 2.months.ago.to_date,
      last_communication_action: pre_nosp_warning_letter,
      eviction_date: nil
    },
    {
      outcome: :no_action,
      nosps_in_last_year: 0,
      nosp_expiry_date: 1.month.ago.to_date,
      weekly_rent: 5,
      balance: 25.0, # 5 * weekly_rent
      is_paused_until: 1.month.from_now,
      active_agreement: false,
      last_communication_date: 2.months.ago.to_date,
      last_communication_action: pre_nosp_warning_letter,
      eviction_date: nil
    },
    {
      outcome: :send_warning_letter,
      nosps_in_last_year: 0,
      nosp_expiry_date: '',
      weekly_rent: 5,
      balance: 25.0, # 5 * weekly_rent
      is_paused_until: nil,
      active_agreement: false,
      last_communication_date: 2.months.ago.to_date,
      last_communication_action: 'ZR2', # Stage 02 Complete / Letter 2 Sent
      eviction_date: nil
    },
    {
      outcome: :no_action,
      nosps_in_last_year: 0,
      nosp_expiry_date: '',
      weekly_rent: 5,
      balance: 25.0, # 5 * weekly_rent
      is_paused_until: nil,
      active_agreement: false,
      last_communication_date: 5.days.ago.to_date,
      last_communication_action: pre_nosp_warning_letter,
      eviction_date: nil
    },
    {
      outcome: :no_action,
      nosps_in_last_year: 0,
      nosp_expiry_date: '',
      weekly_rent: 5,
      balance: 25.0, # 5 * weekly_rent
      is_paused_until: nil,
      active_agreement: false,
      last_communication_date: 8.days.ago.to_date,
      last_communication_action: pre_nosp_warning_letter,
      eviction_date: 2.weeks.ago
    },
    {
      outcome: :no_action,
      nosps_in_last_year: 0,
      nosp_expiry_date: '',
      weekly_rent: 5,
      balance: 25.0, # 5 * weekly_rent
      is_paused_until: nil,
      active_agreement: false,
      last_communication_date: 8.days.ago.to_date,
      last_communication_action: pre_nosp_warning_letter,
      eviction_date: 1.week.from_now
    },
    {
      outcome: :send_NOSP,
      nosps_in_last_year: 0,
      nosp_expiry_date: '',
      weekly_rent: 5,
      balance: 25.0, # 5 * weekly_rent
      is_paused_until: nil,
      active_agreement: false,
      last_communication_date: 8.days.ago.to_date,
      last_communication_action: pre_nosp_warning_letter,
      eviction_date: nil
    },
    {
      outcome: :send_NOSP,
      nosps_in_last_year: 0,
      nosp_expiry_date: 1.month.ago.to_date,
      weekly_rent: 5,
      balance: 25.0, # 5 * weekly_rent
      is_paused_until: nil,
      active_agreement: false,
      last_communication_date: 7.months.ago.to_date,
      last_communication_action: 'ZR2', # Stage 02 Complete / Letter 2 Sent
      eviction_date: nil
    },
    {
      outcome: :send_NOSP,
      nosps_in_last_year: 0,
      nosp_expiry_date: '',
      weekly_rent: 5,
      balance: 25.0, # 5 * weekly_rent
      is_paused_until: nil,
      active_agreement: true,
      last_communication_date: 8.days.ago.to_date,
      last_communication_action: pre_nosp_warning_letter,
      eviction_date: nil
    },
    {
      outcome: :send_NOSP,
      nosps_in_last_year: 0,
      nosp_expiry_date: '',
      weekly_rent: 5,
      balance: 25.0, # 5 * weekly_rent
      is_paused_until: nil,
      active_agreement: false,
      last_communication_date: 8.days.ago.to_date,
      last_communication_action: pre_nosp_warning_letter,
      eviction_date: nil
    }
  ]

  it_behaves_like 'TenancyClassification', send_nosp_condition_matrix
end
