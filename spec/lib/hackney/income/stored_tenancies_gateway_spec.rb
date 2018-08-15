require 'rails_helper'

describe Hackney::Income::StoredTenanciesGateway do
  let(:gateway) { described_class.new }

  context 'when retrieving tenancies' do
    context 'using a single tenancy ref' do
      let(:attributes) do
        {
          tenancy_ref: Faker::Internet.slug,
          priority_band: Faker::Internet.slug,
          priority_score: Faker::Number.number(5).to_i
        }
      end

      subject { gateway.get_tenancies_by_refs([attributes.fetch(:tenancy_ref)]) }

      context 'and the tenancy exists' do
        before do
          Hackney::Income::Models::Tenancy.create(
            tenancy_ref: attributes.fetch(:tenancy_ref),
            priority_band: attributes.fetch(:priority_band),
            priority_score: attributes.fetch(:priority_score)
          )
        end

        it 'should include the tenancy\'s ref, band and score' do
          expect(subject.count).to eq(1)
          expect(subject).to include(a_hash_including(
            tenancy_ref: attributes.fetch(:tenancy_ref),
            priority_band: attributes.fetch(:priority_band),
            priority_score: attributes.fetch(:priority_score)
          ))
        end
      end
    end

    context 'using multiple tenancy refs' do
      let(:multiple_attributes) do
        Faker::Number.number(2).to_i.times.map do
          {
            tenancy_ref: Faker::Internet.slug,
            priority_band: Faker::Internet.slug,
            priority_score: Faker::Number.number(5).to_i
          }
        end
      end

      subject { gateway.get_tenancies_by_refs(multiple_attributes.map { |a| a.fetch(:tenancy_ref) }) }

      context 'and the tenancies exist' do
        before do
          multiple_attributes.map do |attributes|
            Hackney::Income::Models::Tenancy.create(
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
      end
    end
  end

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
