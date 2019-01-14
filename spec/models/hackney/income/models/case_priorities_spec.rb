require 'rails_helper'

describe Hackney::Income::Models::CasePriority do
  context 'when trying to create 2 tenancies with the same reference' do
    let(:tenancy_ref) { Faker::Internet.slug }

    before do
     test_priority = described_class.create!(tenancy_ref: tenancy_ref)
     test_priority.create_case
    end

    it { expect(described_class.first.case).to be_a Hackney::Income::Models::Case}

    it 'should throw an RecordNotUnique exception on the second insert' do
      expect do
        described_class.create!(tenancy_ref: tenancy_ref)
      end.to raise_error(ActiveRecord::RecordNotUnique)
    end
  end
end
