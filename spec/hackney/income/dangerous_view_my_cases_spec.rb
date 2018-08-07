require 'rails_helper'

describe Hackney::Income::DangerousViewMyCases do
  let(:tenancy_attributes) { random_tenancy_attributes }
  let(:tenancy_refs) { [tenancy_attributes.fetch(:ref)] }
  let(:tenancy_priority_band) { Faker::Internet.slug }
  let(:tenancy_priority_score) { Faker::Number.number(5).to_i }
  let(:stored_tenancy_gateway) {  }

  let(:tenancy_api_gateway) do
    TenancyApiGatewayDouble.new({
      tenancy_attributes.fetch(:ref) => tenancy_attributes
    })
  end

  let(:stored_tenancy_gateway) do
    StoredTenancyGatewayDouble.new({
      tenancy_refs.first => { tenancy_ref: tenancy_refs.first, priority_band: tenancy_priority_band, priority_score: tenancy_priority_score }
    })
  end

  let(:use_case) do
    described_class.new(
      tenancy_api_gateway: tenancy_api_gateway,
      stored_tenancy_gateway: stored_tenancy_gateway,
    )
  end

  subject { use_case.execute(tenancy_refs) }

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
        }
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

    let(:stored_tenancy_gateway) do
      StoredTenancyGatewayDouble.new({
        '123/01' => { tenancy_ref: '123/01', priority_band: 'green', priority_score: 12412 },
        '456/01' => { tenancy_ref: '456/01', priority_band: 'red', priority_score: 35663 },
        '789/01' => { tenancy_ref: '789/01', priority_band: 'amber', priority_score: 23124 }
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
      refs.map do |ref|
        @stored_tenancies_attributes.fetch(ref)
      end
    end
  end
end
