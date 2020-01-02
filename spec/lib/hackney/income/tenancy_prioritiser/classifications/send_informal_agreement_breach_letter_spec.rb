require 'rails_helper'

describe 'Send Informal Agreement Breach Letter Rule', type: :feature do
  send_informal_agreement_breach_letter_condition_matrix = [
    {
      # where all conditions are set
      outcome: :send_informal_agreement_breach_letter,
      active_agreement: false,
      balance: 5,
      expected_balance: 10,
      breach_agreement_date: 4.days.ago,
      courtdate: nil,
      latest_active_agreement_date: 7.days.ago,
      last_communication_action: Hackney::Tenancy::ActionCodes::COURT_WARNING_LETTER_SENT,
      last_communication_date: 1.month.ago,
      number_of_broken_agreements: 1
    },
    {
      # when there is a courtdate and court outcome in the past
      outcome: :no_action,
      active_agreement: false,
      courtdate: 5.days.ago,
      latest_active_agreement_date: 7.days.ago,
      court_outcome: 'AGR',
      balance: 5,
      expected_balance: 10,
      breach_agreement_date: 4.days.ago,
      last_communication_action: Hackney::Tenancy::ActionCodes::COURT_WARNING_LETTER_SENT,
      last_communication_date: 1.month.ago,
      number_of_broken_agreements: 1
    },
    {
      # when the expected balance is less than the balance
      outcome: :no_action,
      active_agreement: false,
      balance: 10,
      expected_balance: 5,
      breach_agreement_date: 4.days.ago,
      courtdate: nil,
      latest_active_agreement_date: 7.days.ago,
      last_communication_action: Hackney::Tenancy::ActionCodes::COURT_WARNING_LETTER_SENT,
      last_communication_date: 1.month.ago,
      number_of_broken_agreements: 1
    },
    {
      # where there is an active agreement
      outcome: :no_action,
      active_agreement: true,
      balance: 5,
      expected_balance: 10,
      breach_agreement_date: 4.days.ago,
      courtdate: nil,
      latest_active_agreement_date: 7.days.ago,
      last_communication_action: Hackney::Tenancy::ActionCodes::COURT_WARNING_LETTER_SENT,
      last_communication_date: 1.month.ago,
      number_of_broken_agreements: 1
    },
    {
      # when the breach agreement date is less than 3 days ago
      outcome: :no_action,
      active_agreement: false,
      balance: 5,
      expected_balance: 10,
      breach_agreement_date: 2.days.ago,
      courtdate: nil,
      latest_active_agreement_date: 7.days.ago,
      last_communication_action: Hackney::Tenancy::ActionCodes::COURT_WARNING_LETTER_SENT,
      last_communication_date: 1.month.ago,
      number_of_broken_agreements: 1
    }
    # {
    #   #when the last comminocated action was not a court warning letter sent
    #   #cannot test this as this will incorrectly fall into send_letter_one
    #   outcome: :no_action,
    #   active_agreement: false,
    #   balance: 5,
    #   expected_balance: 10,
    #   breach_agreement_date: 4.days.ago,
    #   courtdate: nil,
    #   latest_active_agreement_date: 7.days.ago,
    #   last_communication_action: 'INCORRECT CODE',
    #   last_communication_date: 1.month.ago,
    #   number_of_broken_agreements: 1
    # }
  ]

  it_behaves_like 'TenancyClassification', send_informal_agreement_breach_letter_condition_matrix
end
