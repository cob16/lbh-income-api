require 'rails_helper'

describe Hackney::Income::UniversalHousingPrioritisationGateway, universal: true do
  subject do
    described_class.new
  end

  context 'when given a tenancy ref' do
    let(:tenancy_ref) { Faker::Internet.slug }
    let(:priority_score) { Faker::Number.number(3) }
    let(:priority_band) { Faker::Internet.slug.to_sym }

    before do
      allow_any_instance_of(Hackney::Income::TenancyPrioritiser).to receive(:priority_score).and_return(priority_score)
      allow_any_instance_of(Hackney::Income::TenancyPrioritiser).to receive(:priority_band).and_return(priority_band)
    end

    it 'should return the priority scores of that tenancy' do
      expect(subject.priorities_for_tenancy(tenancy_ref)).to eq(priority_score: priority_score, priority_band: priority_band)
    end

    it 'should determine universal housing criteria' do
      expect(Hackney::Income::TenancyPrioritiser::UniversalHousingCriteria)
        .to receive(:for_tenancy)
        .with(an_instance_of(Sequel::TinyTDS::Database), tenancy_ref)

      subject.priorities_for_tenancy(tenancy_ref)
    end

    it 'should use universal housing criteria' do
      expect(Hackney::Income::TenancyPrioritiser)
        .to receive(:new)
        .with(criteria: an_instance_of(Hackney::Income::TenancyPrioritiser::UniversalHousingCriteria), weightings: anything)
        .and_call_original

      subject.priorities_for_tenancy(tenancy_ref)
    end

    it 'should use appropriate weightings' do
      expect(Hackney::Income::TenancyPrioritiser)
        .to receive(:new)
        .with(criteria: anything, weightings: an_instance_of(Hackney::Income::TenancyPrioritiser::PriorityWeightings))
        .and_call_original

      subject.priorities_for_tenancy(tenancy_ref)
    end
  end
end
