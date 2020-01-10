require 'rails_helper'

describe 'Apply for Outright Possession Warrant Rule examples' do
  base_example = {
    outcome: :apply_for_outright_possession_warrent,
    active_agreement: false,
    courtdate: 1.month.ago,
    court_outcome: 'OUT'
  }
  examples = [
    base_example,
    base_example.merge(
      desription: 'when the court date is in the future',
      outcome: :no_action,
      active_agreement: false,
      courtdate: 1.week.from_now,
      court_outcome: 'OUT'
    ),
    base_example.merge(
      desription: 'when the court date was more than 3 months ago',
      active_agreement: false,
      outcome: :no_action,
      courtdate: 4.month.ago,
      court_outcome: 'OUT'
    ),
    base_example.merge(
      desription: 'when the court date does not exist',
      active_agreement: false,
      outcome: :no_action,
      courtdate: nil,
      court_outcome: 'OUT'
    ),
    base_example.merge(
      desription: 'when there is an active agreement in place after outright possession order',
      active_agreement: true,
      outcome: :no_action,
      courtdate: 1.month.ago,
      court_outcome: 'OUT'
    )
  ]
  it_behaves_like 'TenancyClassification', examples
end