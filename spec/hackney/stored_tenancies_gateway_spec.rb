require 'rails_helper'

describe Hackney::Income::StoredTenanciesGateway do
  let(:gateway) { described_class.new }

  context 'when storing a tenancy' do
    let(:attributes) do
      {
        tenancy_ref: Faker::Internet.slug,
        priority_band: Faker::Internet.slug,
        priority_score: Faker::Number.number(5).to_i
      }
    end

    subject(:store_tenancy) do
      gateway.store_tenancy(
        tenancy_ref: attributes.fetch(:tenancy_ref),
        priority_band: attributes.fetch(:priority_band),
        priority_score: attributes.fetch(:priority_score)
      )
    end

    context 'and the tenancy does not already exist' do
      let(:created_tenancy) { Hackney::Income::Models::Tenancy.find_by(tenancy_ref: attributes.fetch(:tenancy_ref)) }

      it 'should create the tenancy' do
        store_tenancy
        expect(created_tenancy).to have_attributes(
          tenancy_ref: attributes.fetch(:tenancy_ref),
          priority_band: attributes.fetch(:priority_band),
          priority_score: attributes.fetch(:priority_score)
        )
      end
    end

    context 'and the tenancy already exists' do
      before do
        Hackney::Income::Models::Tenancy.create(
          tenancy_ref: attributes.fetch(:tenancy_ref),
          priority_band: attributes.fetch(:priority_band),
          priority_score: attributes.fetch(:priority_score)
        )
      end

      let(:stored_tenancy) { Hackney::Income::Models::Tenancy.find_by(tenancy_ref: attributes.fetch(:tenancy_ref)) }

      it 'should update the tenancy' do
        store_tenancy
        expect(stored_tenancy).to have_attributes(
          tenancy_ref: attributes.fetch(:tenancy_ref),
          priority_band: attributes.fetch(:priority_band),
          priority_score: attributes.fetch(:priority_score)
        )
      end

      it 'should not create a new tenancy' do
        store_tenancy
        expect(Hackney::Income::Models::Tenancy.count).to eq(1)
      end
    end
  end
end
