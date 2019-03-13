require 'rails_helper'

describe Hackney::Rent::SqlTenanciesMatchingCriteriaGateway do
  subject { described_class.new }

  let(:gateway_model) { described_class::GatewayModel }

  it 'returns an empty array when criteria do not match' do
    expect(subject.criteria_for_green_in_arrears).to eq([])
  end

  context 'when there are red and green tenancies' do
    before {
      create(:case_priority) # green
      create(:case_priority, :red)
    }

    it 'returns only green tenancies' do
      expect(subject.criteria_for_green_in_arrears.count).to eq(1)
      expect(subject.criteria_for_green_in_arrears).to all(be_an(gateway_model))
    end
  end

  context 'when there are diffrent balances' do
    before {
      create(:case_priority, balance: 9.99)
      create(:case_priority, balance: 9)
      create(:case_priority, balance: 10)
      create(:case_priority, balance: 11)
    }

    it 'returns only tenancies that are over £9.99' do
      expect(subject.criteria_for_green_in_arrears.count).to eq(2)
      expect(subject.criteria_for_green_in_arrears).to all(be_an(gateway_model))
    end
  end

  context 'when there are different days in arrears' do
    let(:num_tenancy_under_5_days) { Faker::Number.number(2).to_i }
    let(:num_tenancy_over_and_at_5_days) { Faker::Number.number(2).to_i }

    before do
      num_tenancy_under_5_days.times do
        create(:case_priority, days_in_arrears: Faker::Number.between(0, 4))
      end

      num_tenancy_over_and_at_5_days.times do
        create(:case_priority, days_in_arrears: Faker::Number.between(5, 1000))
      end
    end

    it 'returns only tenancies in arrears for more than 4 days' do
      expect(subject.criteria_for_green_in_arrears.count).to eq(num_tenancy_over_and_at_5_days)
      expect(subject.criteria_for_green_in_arrears).to all(be_an(gateway_model))
    end
  end

  context 'when there are different active agrements' do
    let(:num_tenancy_active) { Faker::Number.number(2).to_i }
    let(:num_tenancy_inactive) { Faker::Number.number(2).to_i }

    before do
      num_tenancy_active.times do
        create(:case_priority, active_agreement: true)
      end
      num_tenancy_inactive.times do
        create(:case_priority, active_agreement: false)
      end
    end

    it 'returns only tenancies that do not have an active agrement' do
      expect(subject.criteria_for_green_in_arrears.count).to eq(num_tenancy_inactive)
      expect(subject.criteria_for_green_in_arrears).to all(be_an(gateway_model))
    end
  end

  context 'when there are paused and unpaused tenancies' do
    let(:num_tenancy_paused) { Faker::Number.number(2).to_i }
    let(:num_tenancy_unpaused) { Faker::Number.number(2).to_i }

    before do
      num_tenancy_unpaused.times do |i|
        # is_paused_until field is nullable
        paused_value = i.even? ? Faker::Date.backward(23).to_s : nil
        create(:case_priority, is_paused_until: paused_value)
      end
      num_tenancy_paused.times do
        create(:case_priority, is_paused_until: Faker::Date.forward(23).to_s)
      end
    end

    it 'returns only unpaused tenancies' do
      expect(subject.criteria_for_green_in_arrears.count).to eq(num_tenancy_unpaused)
      expect(subject.criteria_for_green_in_arrears).to all(be_an(gateway_model))
    end
  end
end
