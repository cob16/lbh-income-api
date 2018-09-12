require 'rails_helper'

describe Hackney::Income::DangerousViewMyCases do
  let(:tenancy_attributes) { random_tenancy_attributes }
  let(:tenancy_priority_factors) { random_tenancy_priority_factors }
  let(:tenancy_refs) { [tenancy_attributes.fetch(:ref)] }
  let(:tenancy_priority_band) { Faker::Internet.slug }
  let(:tenancy_priority_score) { Faker::Number.number(5).to_i }

  let(:tenancy_api_gateway) do
    TenancyApiGatewayDouble.new({
      tenancy_attributes.fetch(:ref) => tenancy_attributes
    })
  end

  let(:stored_tenancies_gateway) do
    StoredTenancyGatewayDouble.new({
      tenancy_refs.first => { tenancy_ref: tenancy_refs.first, priority_band: tenancy_priority_band, priority_score: tenancy_priority_score }.merge(tenancy_priority_factors)
    })
  end

  let(:view_my_cases) do
    described_class.new(
      tenancy_api_gateway: tenancy_api_gateway,
      stored_tenancies_gateway: stored_tenancies_gateway,
    )
  end

  subject { view_my_cases.execute(tenancy_refs) }

  context 'when given no tenancy refs' do
    let(:tenancy_api_gateway) { double(get_tenancies_by_refs: []) }

    it 'should return nothing' do
      expect(subject).to eq([])
    end
  end

  context 'when given a single tenancy ref' do
    it 'should return details for that tenancy' do
      expect(subject.count).to eq(1)
      expect(subject).to include(a_hash_including(
        ref: tenancy_attributes.fetch(:ref),
        current_balance: tenancy_attributes.fetch(:current_balance),
        current_arrears_agreement_status: tenancy_attributes.fetch(:current_arrears_agreement_status),
        latest_action: {
          code: tenancy_attributes.dig(:latest_action, :code),
          date: tenancy_attributes.dig(:latest_action, :date),
        },
        primary_contact: {
          name: tenancy_attributes.dig(:primary_contact, :name),
          short_address: tenancy_attributes.dig(:primary_contact, :short_address),
          postcode: tenancy_attributes.dig(:primary_contact, :postcode),
        },

        balance_contribution: tenancy_priority_factors.fetch(:balance_contribution),
        days_in_arrears_contribution: tenancy_priority_factors.fetch(:days_in_arrears_contribution),
        days_since_last_payment_contribution: tenancy_priority_factors.fetch(:days_since_last_payment_contribution),
        payment_amount_delta_contribution: tenancy_priority_factors.fetch(:payment_amount_delta_contribution),
        payment_date_delta_contribution: tenancy_priority_factors.fetch(:payment_date_delta_contribution),
        number_of_broken_agreements_contribution: tenancy_priority_factors.fetch(:number_of_broken_agreements_contribution),
        active_agreement_contribution: tenancy_priority_factors.fetch(:active_agreement_contribution),
        broken_court_order_contribution: tenancy_priority_factors.fetch(:broken_court_order_contribution),
        nosp_served_contribution: tenancy_priority_factors.fetch(:nosp_served_contribution),
        active_nosp_contribution: tenancy_priority_factors.fetch(:active_nosp_contribution),

        balance: tenancy_priority_factors.fetch(:balance),
        days_in_arrears: tenancy_priority_factors.fetch(:days_in_arrears),
        days_since_last_payment: tenancy_priority_factors.fetch(:days_since_last_payment),
        payment_amount_delta: tenancy_priority_factors.fetch(:payment_amount_delta),
        payment_date_delta: tenancy_priority_factors.fetch(:payment_date_delta),
        number_of_broken_agreements: tenancy_priority_factors.fetch(:number_of_broken_agreements),
        active_agreement: tenancy_priority_factors.fetch(:active_agreement),
        broken_court_order: tenancy_priority_factors.fetch(:broken_court_order),
        nosp_served: tenancy_priority_factors.fetch(:nosp_served),
        active_nosp: tenancy_priority_factors.fetch(:active_nosp)
      ))
    end

    it 'should return priorities for that tenancy' do
      expect(subject.count).to eq(1)
      expect(subject).to include(a_hash_including(
        priority_score: tenancy_priority_score,
        priority_band: tenancy_priority_band
      ))
    end
  end

  context 'when given two tenancy refs' do
    let(:tenancy_refs) { ['123/01', '789/01'] }

    let(:tenancy_api_gateway) do
      TenancyApiGatewayDouble.new({
        '123/01' => random_tenancy_attributes('123/01'),
        '456/01' => random_tenancy_attributes('456/01'),
        '789/01' => random_tenancy_attributes('789/01')
      })
    end

    let(:stored_tenancies_gateway) do
      StoredTenancyGatewayDouble.new({
        '123/01' => { tenancy_ref: '123/01', priority_band: 'green', priority_score: 12412 }.merge(random_tenancy_attributes('123/01')).merge(random_tenancy_priority_factors),
        '456/01' => { tenancy_ref: '456/01', priority_band: 'red', priority_score: 35663 }.merge(random_tenancy_attributes('456/01')).merge(random_tenancy_priority_factors),
        '789/01' => { tenancy_ref: '789/01', priority_band: 'amber', priority_score: 23124 }.merge(random_tenancy_attributes('789/01')).merge(random_tenancy_priority_factors)
      })
    end

    it 'should only return details for those tenancies' do
      expect(subject.count).to eq(2)
      expect(subject.map { |t| t.fetch(:ref) }).to eq(['123/01', '789/01'])
    end

    it 'should match priorities to the correct tenancies' do
      expect(subject).to include(a_hash_including(
        ref: '123/01',
        priority_band: 'green',
        priority_score: 12412
      ))

      expect(subject).to include(a_hash_including(
        ref: '789/01',
        priority_band: 'amber',
        priority_score: 23124
      ))
    end

    context 'and one hasn\'t had data synced' do
      let(:stored_tenancies_gateway) do
        StoredTenancyGatewayDouble.new({
          '123/01' => { tenancy_ref: '123/01', priority_band: 'green', priority_score: 12412 }.merge(random_tenancy_attributes('123/01')).merge(random_tenancy_priority_factors),
        })
      end

      it 'should skip the unsaved tenancy' do
        expect(subject.count).to eq(1)
        expect(subject).to include(a_hash_including(ref: '123/01'))
      end

      it 'should log a warning' do
        expect(Rails.logger).to receive(:warn).with('Tenancy has not been synced and can\'t be requested: "789/01"')
        subject
      end
    end

    context 'and neither has been synced' do
      let(:stored_tenancies_gateway) { StoredTenancyGatewayDouble.new({}) }

      it 'should log two warnings' do
        expect(Rails.logger).to receive(:warn).with('Tenancy has not been synced and can\'t be requested: "123/01"')
        expect(Rails.logger).to receive(:warn).with('Tenancy has not been synced and can\'t be requested: "789/01"')
        subject
      end
    end
  end

  def random_tenancy_priority_factors
    {
      balance_contribution: Faker::Number.number(5),
      days_in_arrears_contribution: Faker::Number.number(5),
      days_since_last_payment_contribution: Faker::Number.number(5),
      payment_amount_delta_contribution: Faker::Number.number(5),
      payment_date_delta_contribution: Faker::Number.number(5),
      number_of_broken_agreements_contribution: Faker::Number.number(5),
      active_agreement_contribution: Faker::Number.number(5),
      broken_court_order_contribution: Faker::Number.number(5),
      nosp_served_contribution: Faker::Number.number(5),
      active_nosp_contribution: Faker::Number.number(5),

      balance: Faker::Commerce.price,
      days_in_arrears: Faker::Number.number(2),
      days_since_last_payment: Faker::Number.number(2),
      payment_amount_delta: Faker::Number.number(4),
      payment_date_delta: Faker::Number.number(1),
      number_of_broken_agreements: Faker::Number.number(1),
      active_agreement: Faker::Number.between(0, 1),
      broken_court_order: Faker::Number.between(0, 1),
      nosp_served: Faker::Number.between(0, 1),
      active_nosp: Faker::Number.between(0, 1)
    }
  end

  def random_tenancy_attributes(tenancy_ref = nil)
    {
      ref: tenancy_ref || Faker::Internet.slug,
      current_balance: Faker::Commerce.price,
      current_arrears_agreement_status: Faker::Internet.slug,
      latest_action: {
        code: Faker::Internet.slug,
        date: Faker::Time.forward(23, :morning)
      },
      primary_contact: {
        name: Faker::TheFreshPrinceOfBelAir.character,
        short_address: Faker::Address.street_address,
        postcode: Faker::Address.postcode
      }
    }
  end

  class TenancyApiGatewayDouble
    def initialize(tenancies_attributes)
      @tenancies_attributes = tenancies_attributes
    end

    def get_tenancies_by_refs(refs)
      refs.map do |ref|
        @tenancies_attributes.fetch(ref)
      end
    end
  end

  class StoredTenancyGatewayDouble
    def initialize(stored_tenancies_attributes)
      @stored_tenancies_attributes = stored_tenancies_attributes
    end

    def get_tenancies_by_refs(refs)
      refs.map { |ref| @stored_tenancies_attributes[ref] }.compact
    end
  end
end
