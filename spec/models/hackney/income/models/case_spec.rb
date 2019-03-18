require 'rails_helper'

RSpec.describe Hackney::Income::Models::Case, type: :model do
  let(:tenancy_ref) { Faker::Internet.slug }

  before do
    test_case = described_class.create!(tenancy_ref: tenancy_ref)
    test_case.create_case_priority
  end

  it { expect(described_class.first).to be_a described_class }
  it { expect(described_class.first.case_priority).to be_a Hackney::Income::Models::CasePriority }
end
