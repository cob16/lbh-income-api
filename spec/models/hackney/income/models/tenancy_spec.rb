require 'rails_helper'

describe Hackney::Income::Models::Tenancy do
  context 'when trying to create 2 tenancies with the same reference' do
    let(:tenancy_ref) { Faker::Internet.slug }

    before do
      Hackney::Income::Models::Tenancy.create!(tenancy_ref: tenancy_ref)
    end

    it 'should throw an RecordNotUnique exception on the second insert' do
      expect do
        Hackney::Income::Models::Tenancy.create!(tenancy_ref: tenancy_ref)
      end.to raise_error(ActiveRecord::RecordNotUnique)
    end
  end
end
