require 'rails_helper'

describe Hackney::Rent::Models::CasePriority do
  before {
    Hackney::Rent::Models::Case.delete_all
  }

  context 'when creating a tenancy, the parent case is created' do
    let(:tenancy_ref) { Faker::Internet.slug }

    it do
      described_class.create!(tenancy_ref: tenancy_ref)
      expect(Hackney::Income::Models::Case.find_by(tenancy_ref: tenancy_ref)).to be_truthy
    end
  end

  context 'when trying to create 2 tenancies with the same reference' do
    let(:tenancy_ref) { Faker::Internet.slug }

    before do
      test_priority = described_class.create!(tenancy_ref: tenancy_ref)
      test_priority.create_case
    end

    it { expect(described_class.first.case).to be_a Hackney::Income::Models::Case }

    it 'throws an RecordNotUnique exception on the second insert' do
      expect do
        described_class.create!(tenancy_ref: tenancy_ref)
      end.to raise_error(ActiveRecord::RecordInvalid, /Validation failed: Case/)
    end
  end
end
