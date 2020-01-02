require 'rails_helper'

describe 'Send Informal Agreement Breach Letter Rule', type: :feature do
  send_informal_agreement_breach_letter_condition_matrix = [
    {
      #where all conditions are set
      outcome: :send_informal_agreement_breach_letter,
      active_agreement: false,
      balance: 5,
      expected_balance: 10,
      courtdate: nil,
      last_communication_action: Hackney::Tenancy::ActionCodes::COURT_WARNING_LETTER_SENT,
      last_communication_date: 1.month.ago,
      number_of_broken_agreements: 1
    },
    {
      #when there is a courtdate and court outcome in the past
      outcome: :no_action,
      active_agreement: false,
      court_date: 5.days.ago,
      court_outcome:'AGR',
      balance: 5,
      expected_balance: 10,
      last_communication_action: Hackney::Tenancy::ActionCodes::COURT_WARNING_LETTER_SENT,
      last_communication_date: 1.month.ago,
      number_of_broken_agreements: 1,
      breach_agreement_date: 2.days.ago
    },
  
  ]

  it_behaves_like 'TenancyClassification', send_informal_agreement_breach_letter_condition_matrix
end
