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
         attributes.fetch(:weightings),
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
        expect(created_tenancy).to have_attributes(
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
    end

    context 'and the tenancy already exists' do
      before do
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
        expect(stored_tenancy).to have_attributes(
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

      it 'should not create a new tenancy' do
        store_tenancy
        expect(Hackney::Income::Models::Tenancy.count).to eq(1)
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
        expect(subject).to include(a_hash_including(
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
        ))
      end
    end

    context 'and the user is assigned multiple tenancies' do
      let(:multiple_attributes) do
        Faker::Number.number(2).to_i.times.map do
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
              priority_score: attributes.fetch(:priority_score)
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
              { tenancy_ref: Faker::Internet.slug, priority_band: 'red', priority_score: 1 },
              { tenancy_ref: Faker::Internet.slug, priority_band: 'green', priority_score: 50 },
              { tenancy_ref: Faker::Internet.slug, priority_band: 'amber', priority_score: 100 },
              { tenancy_ref: Faker::Internet.slug, priority_band: 'green', priority_score: 100 },
              { tenancy_ref: Faker::Internet.slug, priority_band: 'red', priority_score: 101 },
              { tenancy_ref: Faker::Internet.slug, priority_band: 'amber', priority_score: 200 }
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
        Hackney::Income::Models::Tenancy.create!(assigned_user_id: user_id)
        Hackney::Income::Models::Tenancy.create!(assigned_user_id: other_user_id)
        Hackney::Income::Models::Tenancy.create!(assigned_user_id: user_id)
      end

      it 'should only return the user\'s tenancies' do
        expect(subject.count).to eq(2)
      end
    end
  end

  context 'when counting the number of pages of tenancies for a user' do
    let(:user_id) { Faker::Number.number(2).to_i }
    subject { gateway.number_of_pages_for_user(user_id: user_id, number_per_page: number_per_page) }

    context 'and the user has ten tenancies' do
      before { 10.times { create_tenancy(user_id: user_id) } }

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

  def create_tenancy(user_id: nil)
    Hackney::Income::Models::Tenancy.create(assigned_user_id: user_id)
  end
end
