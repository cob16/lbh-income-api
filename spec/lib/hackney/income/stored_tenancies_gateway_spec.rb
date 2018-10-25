# frozen_string_literal: true

require 'rails_helper'

describe Hackney::Income::StoredTenanciesGateway do
  let(:gateway) { described_class.new }

  context 'when storing a tenancy' do
    let(:attributes) do
      {
        tenancy_ref: Faker::Internet.slug,
        priority_band: Faker::Internet.slug,
        priority_score: Faker::Number.number(5).to_i,
        criteria: Hackney::Income::TenancyPrioritiser::StubCriteria.new,
        weightings: Hackney::Income::TenancyPrioritiser::PriorityWeightings.new
      }
    end

    let(:score_calculator) do
      Hackney::Income::TenancyPrioritiser::Score.new(
        attributes.fetch(:criteria),
        attributes.fetch(:weightings)
      )
    end

    subject(:store_tenancy) do
      gateway.store_tenancy(
        tenancy_ref: attributes.fetch(:tenancy_ref),
        priority_band: attributes.fetch(:priority_band),
        priority_score: attributes.fetch(:priority_score),
        criteria: attributes.fetch(:criteria),
        weightings: attributes.fetch(:weightings)
      )
    end

    context 'and the tenancy does not already exist' do
      let(:created_tenancy) { Hackney::Income::Models::Tenancy.find_by(tenancy_ref: attributes.fetch(:tenancy_ref)) }

      it 'should create the tenancy' do
        store_tenancy
        expect(created_tenancy).to have_attributes(expected_serialised_tenancy(attributes))
      end

      # FIXME: shouldn't return AR models from gateways
      it 'should return the tenancy' do
        expect(store_tenancy).to eq(created_tenancy)
      end
    end

    context 'and the tenancy already exists' do
      let!(:pre_existing_tenancy) do
        Hackney::Income::Models::Tenancy.create!(
          tenancy_ref: attributes.fetch(:tenancy_ref),
          priority_band: attributes.fetch(:priority_band),
          priority_score: attributes.fetch(:priority_score),

          balance_contribution: score_calculator.balance,
          days_in_arrears_contribution: score_calculator.days_in_arrears,
          days_since_last_payment_contribution: score_calculator.days_since_last_payment,
          payment_amount_delta_contribution: score_calculator.payment_amount_delta,
          payment_date_delta_contribution: score_calculator.payment_date_delta,
          number_of_broken_agreements_contribution: score_calculator.number_of_broken_agreements,
          active_agreement_contribution: score_calculator.active_agreement,
          broken_court_order_contribution: score_calculator.broken_court_order,
          nosp_served_contribution: score_calculator.nosp_served,
          active_nosp_contribution: score_calculator.active_nosp,

          balance: attributes.fetch(:criteria).balance,
          days_in_arrears: attributes.fetch(:criteria).days_in_arrears,
          days_since_last_payment: attributes.fetch(:criteria).days_since_last_payment,
          payment_amount_delta: attributes.fetch(:criteria).payment_amount_delta,
          payment_date_delta: attributes.fetch(:criteria).payment_date_delta,
          number_of_broken_agreements: attributes.fetch(:criteria).number_of_broken_agreements,
          active_agreement: attributes.fetch(:criteria).active_agreement?,
          broken_court_order: attributes.fetch(:criteria).broken_court_order?,
          nosp_served: attributes.fetch(:criteria).nosp_served?,
          active_nosp: attributes.fetch(:criteria).active_nosp?
        )
      end

      let(:stored_tenancy) { Hackney::Income::Models::Tenancy.find_by(tenancy_ref: attributes.fetch(:tenancy_ref)) }

      it 'should update the tenancy' do
        store_tenancy
        expect(stored_tenancy).to have_attributes(expected_serialised_tenancy(attributes))
      end

      it 'should not create a new tenancy' do
        store_tenancy
        expect(Hackney::Income::Models::Tenancy.count).to eq(1)
      end

      # FIXME: shouldn't return AR models from gateways
      it 'should return the tenancy' do
        expect(store_tenancy).to eq(pre_existing_tenancy)
      end
    end
  end

  context 'when retrieving tenancies by user' do
    let(:user_id) { 1 }
    let(:other_user_id) { 2 }
    subject { gateway.get_tenancies_for_user(user_id: user_id) }

    context 'and the user has no tenancies' do
      it 'should return no tenancies' do
        expect(subject).to eq([])
      end
    end

    context 'and the user is assigned a single tenancy' do
      let(:attributes) do
        {
          tenancy_ref: Faker::Internet.slug,
          priority_band: Faker::Internet.slug,
          priority_score: Faker::Number.number(5).to_i,
          criteria: Hackney::Income::TenancyPrioritiser::StubCriteria.new,
          weightings: Hackney::Income::TenancyPrioritiser::PriorityWeightings.new
        }
      end

      let(:score_calculator) do
        Hackney::Income::TenancyPrioritiser::Score.new(
          attributes.fetch(:criteria),
          attributes.fetch(:weightings)
        )
      end

      before do
        Hackney::Income::Models::Tenancy.create!(
          assigned_user_id: user_id,
          tenancy_ref: attributes.fetch(:tenancy_ref),
          priority_band: attributes.fetch(:priority_band),
          priority_score: attributes.fetch(:priority_score),
          balance_contribution: score_calculator.balance,
          days_in_arrears_contribution: score_calculator.days_in_arrears,
          days_since_last_payment_contribution: score_calculator.days_since_last_payment,
          payment_amount_delta_contribution: score_calculator.payment_amount_delta,
          payment_date_delta_contribution: score_calculator.payment_date_delta,
          number_of_broken_agreements_contribution: score_calculator.number_of_broken_agreements,
          active_agreement_contribution: score_calculator.active_agreement,
          broken_court_order_contribution: score_calculator.broken_court_order,
          nosp_served_contribution: score_calculator.nosp_served,
          active_nosp_contribution: score_calculator.active_nosp,

          balance: attributes.fetch(:criteria).balance,
          days_in_arrears: attributes.fetch(:criteria).days_in_arrears,
          days_since_last_payment: attributes.fetch(:criteria).days_since_last_payment,
          payment_amount_delta: attributes.fetch(:criteria).payment_amount_delta,
          payment_date_delta: attributes.fetch(:criteria).payment_date_delta,
          number_of_broken_agreements: attributes.fetch(:criteria).number_of_broken_agreements,
          active_agreement: attributes.fetch(:criteria).active_agreement?,
          broken_court_order: attributes.fetch(:criteria).broken_court_order?,
          nosp_served: attributes.fetch(:criteria).nosp_served?,
          active_nosp: attributes.fetch(:criteria).active_nosp?
        )
      end

      it 'should include the tenancy\'s ref, band and score' do
        expect(subject.count).to eq(1)
        expect(subject).to include(a_hash_including(expected_serialised_tenancy(attributes)))
      end
    end

    context 'and the user is assigned multiple tenancies' do
      let(:multiple_attributes) do
        Array.new(Faker::Number.number(2).to_i) do
          {
            tenancy_ref: Faker::Internet.slug,
            priority_band: Faker::Internet.slug,
            priority_score: Faker::Number.number(5).to_i
          }
        end
      end

      context 'and the tenancies exist' do
        before do
          multiple_attributes.map do |attributes|
            Hackney::Income::Models::Tenancy.create!(
              assigned_user_id: user_id,
              tenancy_ref: attributes.fetch(:tenancy_ref),
              priority_band: attributes.fetch(:priority_band),
              priority_score: attributes.fetch(:priority_score),
              balance: 1
            )
          end
        end

        it 'should include the tenancy\'s ref, band and score' do
          expect(subject.count).to eq(multiple_attributes.count)

          multiple_attributes.each do |attributes|
            expect(subject).to include(a_hash_including(
                                         tenancy_ref: attributes.fetch(:tenancy_ref),
                                         priority_band: attributes.fetch(:priority_band),
                                         priority_score: attributes.fetch(:priority_score)
                                       ))
          end
        end

        context 'and the cases are assigned different bands and scores' do
          let(:multiple_attributes) do
            [
              { tenancy_ref: Faker::Internet.slug, priority_band: 'red', priority_score: 1, balance: 1 },
              { tenancy_ref: Faker::Internet.slug, priority_band: 'green', priority_score: 50, balance: 1 },
              { tenancy_ref: Faker::Internet.slug, priority_band: 'amber', priority_score: 100, balance: 1 },
              { tenancy_ref: Faker::Internet.slug, priority_band: 'green', priority_score: 100, balance: 1 },
              { tenancy_ref: Faker::Internet.slug, priority_band: 'red', priority_score: 101, balance: 1 },
              { tenancy_ref: Faker::Internet.slug, priority_band: 'amber', priority_score: 200, balance: 1 }
            ]
          end

          let(:cases) do
            subject.map do |c|
              { band: c.fetch(:priority_band), score: c.fetch(:priority_score).to_i }
            end
          end

          it 'should sort by band, then score' do
            expect(cases).to eq([
              { band: 'red', score: 101 },
              { band: 'red', score: 1 },
              { band: 'amber', score: 200 },
              { band: 'amber', score: 100 },
              { band: 'green', score: 100 },
              { band: 'green', score: 50 }
            ])
          end

          context 'and page number is set to one, and number per page is set to two' do
            subject { gateway.get_tenancies_for_user(user_id: user_id, page_number: 1, number_per_page: 2) }

            it 'should only return the first two' do
              expect(cases).to eq([
                { band: 'red', score: 101 },
                { band: 'red', score: 1 }
              ])
            end
          end

          context 'and page number is set to two, and number per page is set to three' do
            subject { gateway.get_tenancies_for_user(user_id: user_id, page_number: 2, number_per_page: 3) }

            it 'should only return the last three' do
              expect(cases).to eq([
                { band: 'amber', score: 100 },
                { band: 'green', score: 100 },
                { band: 'green', score: 50 }
              ])
            end
          end
        end
      end
    end

    context 'and tenancies exist which aren\'t assigned to the user' do
      before do
        Hackney::Income::Models::Tenancy.create!(assigned_user_id: user_id, balance: 1)
        Hackney::Income::Models::Tenancy.create!(assigned_user_id: other_user_id, balance: 1)
        Hackney::Income::Models::Tenancy.create!(assigned_user_id: user_id, balance: 1)
      end

      it 'should only return the user\'s tenancies' do
        expect(subject.count).to eq(2)
      end
    end
  end

  context 'when counting the number of pages of tenancies for a user' do
    let(:user_id) { Faker::Number.number(2).to_i }
    subject { gateway.number_of_pages_for_user(user_id: user_id, number_per_page: number_per_page) }

    context 'and the user has ten tenancies in arrears, and ten not in arrears' do
      before do
        10.times { create_tenancy(user_id: user_id, balance: 1) }
        10.times { create_tenancy(user_id: user_id, balance: -1) }
      end

      context 'and the number per page is five' do
        let(:number_per_page) { 5 }
        it { is_expected.to eq(2) }
      end
    end

    context 'and the user has nine tenancies' do
      before { 9.times { create_tenancy(user_id: user_id) } }

      context 'and the number per page is five' do
        let(:number_per_page) { 5 }
        it { is_expected.to eq(2) }
      end
    end

    context 'and the user has twelve tenancies' do
      before { 12.times { create_tenancy(user_id: user_id) } }

      context 'and the number per page is three' do
        let(:number_per_page) { 3 }
        it { is_expected.to eq(4) }
      end
    end

    context 'and the user is not the only assignee' do
      let(:other_user_id) { Faker::Number.number(3).to_i }

      before do
        6.times { create_tenancy(user_id: user_id) }
        6.times { create_tenancy(user_id: other_user_id) }
      end

      context 'and the number per page is three' do
        let(:number_per_page) { 3 }
        it { is_expected.to eq(2) }
      end
    end
  end

  context 'there are paused and paused tenancies' do
    let(:is_paused) { nil }
    let(:user_id) { Faker::Number.number(2).to_i }

    let(:num_paused_cases) { Faker::Number.between(2, 10) }
    let(:num_active_cases) { Faker::Number.between(2, 20) }
    let(:num_pages) { Faker::Number.between(1, 5) }

    before do
      num_paused_cases.times do
        create_tenancy(user_id: user_id, balance: 40, is_paused_until: Faker::Date.forward(1))
      end
      (num_active_cases - 2).times do
        create_tenancy(user_id: user_id, balance: 40)
      end
      2.times do
        create_tenancy(user_id: user_id, balance: 40, is_paused_until: Faker::Date.backward(1))
      end
    end

    context 'when we call get_tenancies_for_user' do
      let(:is_paused) { nil }
      subject do
        gateway.get_tenancies_for_user(
          user_id: user_id,
          page_number: 1,
          number_per_page: 50,
          is_paused: is_paused
        )
      end

      it 'should return all tenancies' do
        expect(subject.count).to eq(num_paused_cases + num_active_cases)
      end

      context 'when and is_paused is set true' do
        let(:is_paused) { true }

        it 'should only return only paused tenancies' do
          expect(subject.count).to eq(num_paused_cases)
        end
      end

      context 'and is_paused is set false' do
        let(:is_paused) { false }

        it 'should only return unpaused tenancies' do
          expect(subject.count).to eq(num_active_cases)
        end
      end
    end

    context 'when we call number_of_pages_for_user' do
      subject do
        gateway.number_of_pages_for_user(
          user_id: user_id,
          number_per_page: num_pages,
          is_paused: is_paused
        )
      end

      context 'and is_paused is set false' do
        let(:is_paused) { false }

        it 'should show the number pages of of paused cases' do
          expect(subject).to eq(expected_num_pages(num_active_cases, num_pages))
        end
      end

      context 'and is_paused is set true' do
        let(:is_paused) { true }

        it 'should show the number pages of of paused cases' do
          expect(subject).to eq(expected_num_pages(num_paused_cases, num_pages))
        end
      end

      context 'and is_paused is not set' do
        let(:is_paused) { nil }

        it 'should show the number pages of of paused cases' do
          expect(subject).to eq(expected_num_pages((num_paused_cases + num_active_cases), num_pages))
        end
      end
    end
  end

  def expected_num_pages(items, number_per_page)
    (items.to_f / number_per_page).ceil
  end

  def create_tenancy(user_id: nil, balance: 1, is_paused_until: nil)
    Hackney::Income::Models::Tenancy.create(assigned_user_id: user_id, balance: balance, is_paused_until: is_paused_until)
  end

  def expected_serialised_tenancy(attributes)
    {
      tenancy_ref: attributes.fetch(:tenancy_ref),
      priority_band: attributes.fetch(:priority_band),
      priority_score: attributes.fetch(:priority_score),

      balance_contribution: score_calculator.balance,
      days_in_arrears_contribution: score_calculator.days_in_arrears,
      days_since_last_payment_contribution: score_calculator.days_since_last_payment,
      payment_amount_delta_contribution: score_calculator.payment_amount_delta,
      payment_date_delta_contribution: score_calculator.payment_date_delta,
      number_of_broken_agreements_contribution: score_calculator.number_of_broken_agreements,
      active_agreement_contribution: score_calculator.active_agreement,
      broken_court_order_contribution: score_calculator.broken_court_order,
      nosp_served_contribution: score_calculator.nosp_served,
      active_nosp_contribution: score_calculator.active_nosp,

      balance: attributes.fetch(:criteria).balance,
      days_in_arrears: attributes.fetch(:criteria).days_in_arrears,
      days_since_last_payment: attributes.fetch(:criteria).days_since_last_payment,
      payment_amount_delta: attributes.fetch(:criteria).payment_amount_delta,
      payment_date_delta: attributes.fetch(:criteria).payment_date_delta,
      number_of_broken_agreements: attributes.fetch(:criteria).number_of_broken_agreements,
      active_agreement: attributes.fetch(:criteria).active_agreement?,
      broken_court_order: attributes.fetch(:criteria).broken_court_order?,
      nosp_served: attributes.fetch(:criteria).nosp_served?,
      active_nosp: attributes.fetch(:criteria).active_nosp?
    }
  end
end
