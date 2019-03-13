require 'rails_helper'

describe Hackney::Rent::AssignTenancyToUser do
  subject { described_class.new(user_assignment_gateway: gateway) }

  let!(:user1) { create(:user, :credit_controller) }
  let!(:user2) { create(:user, :credit_controller) }

  let!(:assigned_case) { create(:case_priority, assigned_user: user2) }
  let!(:unassigned_case) { create(:case_priority, assigned_user_id: nil) }

  let(:gateway) { double('UserAssignmentGateway') }

  before do
    allow(gateway).to receive(:assign_to_next_available_user).with(tenancy: unassigned_case).and_return(user1.id)
  end

  context 'when trying to assign a case already assigned' do
    it 'does not assign the case' do
      expect(gateway).not_to receive(:assign_to_next_available_user)

      expect(subject.assign(tenancy: assigned_case)).to eq(user2.id)
    end
  end

  context 'when trying to assign a new case' do
    it 'passes the case to the assignment gateway and return the assigned user id' do
      expect(subject.assign(tenancy: unassigned_case)).to eq(user1.id)
      expect(gateway).to have_received(:assign_to_next_available_user).with(
        tenancy: unassigned_case
      )
    end
  end
end
