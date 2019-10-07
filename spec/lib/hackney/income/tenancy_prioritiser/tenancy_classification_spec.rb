require 'rails_helper'

describe Hackney::Income::TenancyPrioritiser::TenancyClassification do
  subject { assign_classification.execute }

  let(:criteria) { Stubs::StubCriteria.new }
  let(:assign_classification) { described_class.new(criteria) }

  context 'when arears are more than £5' do
    it 'can classifiy to send SMS' do
      last_week = 8.days.ago.to_date
      criteria.balance = 6.00
      criteria.nosp_served = false
      criteria.last_communication_date = last_week.to_date
      criteria.paused = false
      expect(subject).to eq(:send_first_SMS)
    end
    it 'will not classify to send an SMS if the last comunication date was over 3 months ago' do
      last_week = 92.days.ago.to_date
      criteria.balance = 6.00
      criteria.nosp_served = false
      criteria.last_communication_date = last_week.to_date
      criteria.paused = false
      expect(subject).to eq(nil)
    end
  end

  it 'can classify to send letter one when arears are more than £10' do
    last_week = 8.days.ago.to_date
    criteria.balance = 11.00
    criteria.nosp_served = false
    criteria.last_communication_date = last_week.to_date
    criteria.last_communication_action = 'SMS'
    criteria.paused = false
    expect(subject).to eq(:send_letter_one)
  end
  it 'can classify to send letter two when the tenant has missed at least one weeks rent' do
    last_week = 8.days.ago.to_date
    weekly_rent = criteria.weekly_rent
    criteria.balance = weekly_rent + 1
    criteria.nosp_served = false
    criteria.last_communication_date = last_week.to_date
    criteria.last_communication_action = 'C'
    criteria.paused = false
    expect(subject).to eq(:send_letter_two)
  end
  it 'can classify to send a warning letter when the tenant has missed at least three weeks rent' do
    last_week = 8.days.ago.to_date
    weekly_rent = criteria.weekly_rent
    criteria.balance = (weekly_rent * 3) + 1
    criteria.nosp_served = false
    criteria.last_communication_date = last_week.to_date
    criteria.last_communication_action = 'LL2'
    criteria.paused = false
    expect(subject).to eq(:send_warning_letter)
  end
  it 'can classify to send a NOSP when the tenant has missed 4 weeks worth of rent' do
    last_week = 8.days.ago.to_date
    weekly_rent = criteria.weekly_rent
    criteria.balance = (weekly_rent * 4) + 1
    criteria.nosp_served = false
    criteria.last_communication_date = last_week.to_date
    criteria.last_communication_action = 'ZW2'
    criteria.paused = false
    expect(subject).to eq(:send_NOSP)
  end
end
