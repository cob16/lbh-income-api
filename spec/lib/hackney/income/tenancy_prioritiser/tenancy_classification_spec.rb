require 'rails_helper'

describe Hackney::Income::TenancyPrioritiser::TenancyClassification do
  subject { assign_classification.execute }

  let(:criteria) { Stubs::StubCriteria.new }
  let(:assign_classification) { described_class.new(criteria) }

  context 'when there are no arrears' do
    balances = {
      in_credit: -3.00,
      under_five_pounds: 4.00,
      just_under_five_pounds: 4.99
    }

    balances.each do |key, balance|
      it "can classifiy a no action tenancy when the arrear level is #{key}" do
        criteria.balance = balance
        criteria.nosp_served = false
        criteria.last_communication_date = 8.days.ago.to_date
        criteria.paused = false
        expect(subject).to eq(:no_action)
      end
    end

    it 'can classifiy a no action tenancy when the last action taken was over three months ago' do
      criteria.balance = 5.00
      criteria.nosp_served = false
      criteria.last_communication_date = 3.months.ago.to_date - 1.day
      criteria.paused = false
      expect(subject).to eq(:no_action)
    end

    it 'can classifiy a no action tenancy when the last communication date was less than a week ago' do
      criteria.balance = 5.00
      criteria.nosp_served = false
      criteria.last_communication_date = 6.days.ago.to_date
      criteria.paused = false
      expect(subject).to eq(:no_action)
    end

    it 'can classifiy a no action tenancy when the the case has been paused' do
      criteria.balance = 15.00
      criteria.nosp_served = false
      criteria.last_communication_date = 6.days.ago.to_date
      criteria.paused = true
      expect(subject).to eq(:no_action)
    end

    it 'can classifiy a no action tenancy when a NOSP has been served' do
      criteria.balance = 5.00
      criteria.nosp_served = true
      criteria.last_communication_date = 8.days.ago.to_date
      criteria.paused = false
      expect(subject).to eq(:no_action)
    end
  end

  context 'when no nosps have been served and the cases are not paused' do
    before do
      criteria.nosp_served = false
      criteria.paused = false
    end

    context 'when arrears level is greater than or equal to £5 and less than £10' do
      balances = {
        five_pounds: 5.00,
        just_over_five_pounds: 5.01,
        over_five_pounds: 6.00,
        just_under_ten_pounds: 9.99
      }
      balances.each do |key, balance|
        it "can classifiy a send SMS tenancy when the arrear level is #{key}" do
          criteria.balance = balance
          criteria.last_communication_action = nil
          criteria.last_communication_date = 8.days.ago.to_date
          expect(subject).to eq(:send_first_SMS)
        end
      end

      last_communication_dates = {
        seven_days_ago: 7.days.ago.to_date,
        eight_days_ago: 8.days.ago.to_date,
        within_three_months: 3.months.ago.to_date
      }
      last_communication_dates.each do |key, last_communication_date|
        it "can classifiy a send SMS tenancy when the last communication date is #{key}" do
          criteria.balance = 5
          criteria.last_communication_action = nil
          criteria.last_communication_date = last_communication_date
          expect(subject).to eq(:send_first_SMS)
        end
      end
    end

    context 'when the arrears are greater than or equal to £10 and less than one week rent' do
      last_communication_actions = {
        green_SMS_sent_auto: 'GAT',
        green_SMS_sent_manual:'GMS'
      }
      last_communication_actions.each do |key, last_communication_action|
        it "can classify to send letter one when arrears are more than £10 with a last communication action of #{key} " do
          criteria.balance = 11.00
          criteria.last_communication_date = 8.days.ago.to_date
          criteria.last_communication_action = last_communication_action
          expect(subject).to eq(:send_letter_one)
        end
      end
    end

    context 'when the arrears are greater than or equal to one weeks rent and less than 3 week rent' do
      last_communication_actions = {
        letter_one_in_arrears_auto: 'IC1',
        letter_one_in_arrears_manual:'IM1'
      }
      last_communication_actions.each do |key, last_communication_action|
        it "can classify to send letter two when the tenant has arreas of 1 week with a last communication action of #{key}" do
          criteria.balance = criteria.weekly_rent
          criteria.last_communication_date = 8.days.ago.to_date
          criteria.last_communication_action = last_communication_action
          expect(subject).to eq(:send_letter_two)
        end
      end

      last_communication_actions.each do |key, last_communication_action|
        it "can classify to send letter two when the tenant is over 1 weeks in arrears with a last communication action of #{key}"  do
          criteria.balance = criteria.weekly_rent
          criteria.last_communication_date = 8.days.ago.to_date + 1.day
          criteria.last_communication_action = last_communication_action
          expect(subject).to eq(:send_letter_two)
        end
      end 

      last_communication_actions.each do |key, last_communication_action|
        it "can classify to send letter two when the tenant has just under 3 weeks with a last communication action of #{key}" do
          criteria.balance = (criteria.weekly_rent * 3) - 1
          criteria.last_communication_date = 8.days.ago.to_date
          criteria.last_communication_action = last_communication_action
          expect(subject).to eq(:send_letter_two)
        end
      end
    end

    context 'when the arrears are greater than or equal to three weeks rent and less than 4 week rent' do
      last_communication_actions = {
        letter_two_in_arrears_auto: 'IC2',
        letter_two_in_arrears_manual:'IM2'
      }
      last_communication_actions.each do |key, last_communication_action|
        it "can classify to send a warning letter when the tenant has missed three weeks rent with a last communication action of #{key}" do
          criteria.balance = criteria.weekly_rent * 3
          criteria.last_communication_date = 8.days.ago.to_date
          criteria.last_communication_action = last_communication_action
          expect(subject).to eq(:send_warning_letter)
        end
      end

      last_communication_actions.each do |key, last_communication_action|
        it "can classify to send a warning letter when the tenant has missed just under 4 weeks rent with a last communication action of #{key}" do
          criteria.balance = (criteria.weekly_rent * 4) - 1
          criteria.last_communication_date = 8.days.ago.to_date
          criteria.last_communication_action = last_communication_action
          expect(subject).to eq(:send_warning_letter)
        end
      end
    end

    context 'when the arrears are greater than or equal 4 week rent' do
      last_communication_actions = {
        pre_nosp_warning_letter_auto: 'IC3',
        pre_nosp_warning_letter_manual:'IM3'
      }
      last_communication_actions.each do |key, last_communication_action|
        it "can classify to send a NOSP when the tenant has missed 4 weeks worth of rent with a last communication action of #{key}" do
          criteria.balance = criteria.weekly_rent * 4
          criteria.last_communication_date = 8.days.ago.to_date
          criteria.last_communication_action = last_communication_action
          expect(subject).to eq(:send_NOSP)
        end
      end
      last_communication_actions.each do |key, last_communication_action|
        it "can classify to send a NOSP when the tenant has missed over 4 weeks worth of rent with a last communication action of #{key}" do
          criteria.balance = (criteria.weekly_rent * 4) + 1
          criteria.last_communication_date = 8.days.ago.to_date
          criteria.last_communication_action = last_communication_action
          expect(subject).to eq(:send_NOSP)
        end
      end
    end
  end
end
