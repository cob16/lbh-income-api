require 'rails_helper'

describe Hackney::Income::TenancyPrioritiser::Score do
  subject { described_class.new(criteria, weightings) }

  let(:criteria) { Stubs::StubCriteria.new(attributes) }
  let(:weightings) { Hackney::Income::TenancyPrioritiser::PriorityWeightings.new }

  let(:attributes) do
    {
      weekly_rent: nil,
      balance: nil,
      nosp_served: nil,
      last_communication_date: nil,
      last_communication_action: nil,
      days_in_arrears: nil,
      days_since_last_payment: nil,
      active_agreement: nil,
      number_of_broken_agreements: nil,
      broken_court_order: nil,
      payment_date_delta: nil,
      payment_amount_delta: nil
    }
  end

  context 'when assigning a score based on all criteria' do
    it 'assigns a composite score based on all of the existing factors' do
      attributes[:days_since_last_payment] = 7
      expect(subject.score).to eq(137.5)
    end

    it 'assigns a higher score for a more pressing case within the same band' do
      attributes[:days_since_last_payment] = 10
      attributes[:balance] = 300.25
      attributes[:payment_amount_delta] = 10

      expect(subject.score).to eq(390.8)
    end

    it 'also assigns a lower score within the same band' do
      attributes[:days_since_last_payment] = 3
      attributes[:balance] = 3.50

      expect(subject.score).to eq(14.7)
    end

    it 'could mean an amber case has a lower overall score than one still green' do
      attributes[:days_since_last_payment] = 14
      attributes[:balance] = 349.99
      attributes[:payment_amount_delta] = 100

      expect(subject.score).to eq(558.488)

      attributes[:days_since_last_payment] = 2
      attributes[:balance] = 351

      expect(subject.score).to eq(531.7)
    end

    it 'has a reasonably definite lower bound' do
      attributes[:days_since_last_payment] = 1
      attributes[:balance] = 0.01

      expect(subject.score).to eq(10.512)
    end

    it 'does not have a set upper bound' do
      attributes[:balance] = 1050.00
      attributes[:broken_court_order] = true
      attributes[:days_in_arrears] = 210
      attributes[:number_of_broken_agreements] = 5
      attributes[:nosp_served] = true
      attributes[:payment_date_delta] = 30
      attributes[:payment_amount_delta] = 500
      attributes[:active_agreement] = false
      attributes[:active_nosp] = true
      attributes[:days_since_last_payment] = 210

      expect(subject.score).to eq(9075.0)
    end

    it 'is mostly driven by the balance once other factors would be considered red' do
      attributes[:balance] = 10_000.00
      attributes[:broken_court_order] = true
      attributes[:days_in_arrears] = 210
      attributes[:number_of_broken_agreements] = 5
      attributes[:nosp_served] = true
      attributes[:payment_date_delta] = 30
      attributes[:payment_amount_delta] = 500
      attributes[:active_agreement] = false
      attributes[:active_nosp] = true
      attributes[:days_since_last_payment] = 210

      expect(subject.score).to eq(19_815.00)
    end

    it 'can also provide a normalised score' do
      attributes[:days_since_last_payment] = 7

      expect(subject.execute).to eq(4)
    end

    it 'normalises the score into a more usable range' do
      attributes[:balance] = 10_000.00
      attributes[:broken_court_order] = true
      attributes[:days_in_arrears] = 210
      attributes[:number_of_broken_agreements] = 5
      attributes[:nosp_served] = true
      attributes[:payment_date_delta] = 30
      attributes[:payment_amount_delta] = 500
      attributes[:active_agreement] = false
      attributes[:active_nosp] = true
      attributes[:days_since_last_payment] = 210

      expect(subject.execute).to eq(982)
    end
  end

  context 'when examining the breakdown of individual contributions to score' do
    it 'contributes the balance' do
      weightings.balance = 1.2
      attributes[:balance] = 500.00

      expect(subject.balance).to eq(600)
    end

    it 'contributes more for a higher balance' do
      weightings.balance = 1.2
      attributes[:balance] = 1000.00

      expect(subject.balance).to eq(1200)
    end

    it 'barely contributes if the balance is very small' do
      weightings.balance = 1.2
      attributes[:balance] = 5.00

      expect(subject.balance).to eq(6)
    end

    it 'contributes debt age' do
      weightings.days_in_arrears = 1.5
      attributes[:days_in_arrears] = 10

      expect(subject.days_in_arrears).to eq(15)
    end

    it 'contributes more for long term debt' do
      weightings.days_in_arrears = 1.5
      attributes[:days_in_arrears] = 100

      expect(subject.days_in_arrears).to eq(150)
    end

    it 'contributes the days since last payment' do
      weightings.days_since_last_payment = 1
      attributes[:days_since_last_payment] = 10

      expect(subject.days_since_last_payment).to eq(10)
    end

    it 'considers days since last payment to be much more severe as weeks pass' do
      weightings.days_since_last_payment = 1
      attributes[:days_since_last_payment] = 30

      expect(subject.days_since_last_payment).to eq(120)
    end

    it 'considers difference in amount paid between payments' do
      weightings.payment_amount_delta = 1
      attributes[:payment_amount_delta] = -50

      expect(subject.payment_amount_delta).to eq(-50)
    end

    it 'applies no score modifier for a nil delta' do
      weightings.payment_amount_delta = 1
      attributes[:payment_amount_delta] = nil

      expect(subject.payment_amount_delta).to eq(0)
    end

    it 'applies the delta directly to the score, as a positive delta means paid less than previous payment' do
      weightings.payment_amount_delta = 1
      attributes[:payment_amount_delta] = 150

      expect(subject.payment_amount_delta).to eq(150)
    end

    it 'considers irregularity in payment date' do
      weightings.payment_date_delta = 5
      attributes[:payment_date_delta] = 3

      expect(subject.payment_date_delta).to eq(15)
    end

    it 'applies the date delta as if it was positve, as a longer or shorter gap between payments is irregular' do
      weightings.payment_date_delta = 5
      attributes[:payment_date_delta] = -4

      expect(subject.payment_date_delta).to eq(20)
    end

    it 'applies no score modifier if the date delta is nil' do
      weightings.payment_date_delta = 5
      attributes[:payment_date_delta] = nil

      expect(subject.payment_date_delta).to eq(0)
    end

    it 'applies a score addition to a broken agreement' do
      weightings.number_of_broken_agreements = 50
      attributes[:number_of_broken_agreements] = 1

      expect(subject.number_of_broken_agreements).to eq(50)
    end

    it 'applies greater penalties as the number of agreements gets higher' do
      weightings.number_of_broken_agreements = 50
      attributes[:number_of_broken_agreements] = 5

      expect(subject.number_of_broken_agreements).to eq(300)
    end

    it 'applies a score to having a live agreement' do
      weightings.active_agreement = -100
      attributes[:active_agreement] = true

      expect(subject.active_agreement).to eq(-100)
    end

    it 'will apply the live agreement weighting directly' do
      weightings.active_agreement = 100
      attributes[:active_agreement] = true

      expect(subject.active_agreement).to eq(100)
    end

    it 'will apply a score to having a broken court ordered agreement' do
      weightings.broken_court_order = 200
      attributes[:broken_court_order] = true

      expect(subject.broken_court_order).to eq(200)
    end

    it 'will not apply a score if broken agreements are not court-ordered' do
      weightings.broken_court_order = 300
      attributes[:broken_court_order] = false
      attributes[:number_of_broken_agreements] = 2

      expect(subject.broken_court_order).to eq(nil)
    end

    it 'will apply a score if there is a valid nosp' do
      weightings.nosp_served = 20
      attributes[:nosp_served] = true

      expect(subject.nosp_served).to eq(20)
    end

    it 'will apply a score if there is an active nosp' do
      weightings.active_nosp = 50
      attributes[:active_nosp] = true

      expect(subject.active_nosp).to eq(50)
    end

    it 'will apply active nosp score over valid nosp' do
      weightings.active_nosp = 100
      attributes[:active_nosp] = true
      weightings.nosp_served = 250
      attributes[:nosp_served] = true

      expect(subject.active_nosp).to eq(100)
      expect(subject.nosp_served).to eq(nil)
    end
  end
end
