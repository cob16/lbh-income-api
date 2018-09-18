require 'rails_helper'

describe Hackney::Income::AssignTenancyToUser do
  let!(:user1) { Hackney::Income::Models::User.create(name: Faker::Name.name) }
  let!(:user2) { Hackney::Income::Models::User.create(name: Faker::Name.name) }
  let!(:assigned_tenancy) { create_assigned_tenancy_model(band: 'green', user: user2) }
  let!(:unassigned_tenancy) { create_assigned_tenancy_model(band: 'green', user: nil) }

  let(:gateway) { double('UserAssignmentGateway') }
  subject { described_class.new(user_assignment_gateway: gateway)}

  before do
    allow(gateway).to receive(:assign_to_next_available_user).with(tenancy: unassigned_tenancy).and_return(user1.id)
  end

  context 'when trying to assign a tenancy already assigned' do
    it 'should not assign the tenancy' do
      expect(gateway).to_not receive(:assign_to_next_available_user)

      expect(subject.assign(tenancy: assigned_tenancy)).to eq(user2.id)
    end
  end

  context 'when trying to assign a new tenancy' do
    it 'should pass the tenancy to the assignment gateway and return the assigned user id' do
      expect(gateway).to receive(:assign_to_next_available_user).with(
        tenancy: unassigned_tenancy
      )

      expect(subject.assign(tenancy: unassigned_tenancy)).to eq(user1.id)
    end
  end

  def create_assigned_tenancy_model(band:, user:)
    tenancy = Hackney::Income::Models::Tenancy.new.tap do |t|
      t.tenancy_ref = Faker::Lorem.characters(5)
      t.priority_band = band
      t.priority_score = Faker::Lorem.characters(5)
      t.assigned_user = user
    end

    tenancy.save
    tenancy
  end
end
