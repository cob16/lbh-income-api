require 'rails_helper'

describe Hackney::Income::SqlTenancyCaseGateway do
  subject { described_class.new }
  let(:gateway_model) { described_class::GatewayModel }

  context 'when persisting tenancies which do not exist in the database' do
    let(:tenancies) do
      random_size_array = (0..Faker::Number.between(1, 10)).to_a
      random_size_array.map { create_tenancy_model }
    end

    before do
      subject.persist(tenancies: tenancies)
    end

    it 'should save the tenancies in the database' do
      tenancies.each do |tenancy|
        expect(gateway_model.exists?(tenancy_ref: tenancy.tenancy_ref)).to be_truthy
      end
    end
  end

  context 'when persisting a tenancy which already exists in the database' do
    let(:tenancy) { create_tenancy_model }
    let(:existing_tenancy_record) do
      gateway_model.create!(tenancy_ref: tenancy.tenancy_ref)
    end

    before do
      existing_tenancy_record
      subject.persist(tenancies: [tenancy])
    end

    it 'should not create a new record' do
      expect(gateway_model.count).to eq(1)
    end
  end

  context 'when assigning a user to a case' do
    let!(:tenancy_ref) { Faker::Number.number(6) }
    let!(:tenancy) { gateway_model.create(tenancy_ref: tenancy_ref) }
    let!(:user) { Hackney::Income::Models::User.create }

    it 'should assign the user' do
      subject.assign_user(tenancy_ref: tenancy_ref, user_id: user.id)
      expect(tenancy.reload).to have_attributes(
        assigned_user: user
      )
    end

    it 'should raise an exception when assigning a non existing case to user' do
      expect do
        subject.assign_user(
          tenancy_ref: 'not_a_real_tenancy_ref',
          user_id: user.id
        )
      end
        .to raise_error
              .with_message('Unable to assign user 1 to tenancy not_a_real_tenancy_ref - tenancy not found.')
    end
  end

  context 'when retrieving cases assigned to a user' do
    let(:assignee_id) { 1 }
    let(:assigned_tenancies) { subject.assigned_tenancies(assignee_id: assignee_id) }

    context 'and the user has no assigned cases' do
      it 'should return no cases' do
        expect(assigned_tenancies).to be_empty
      end
    end

    context 'and the user has one assigned case' do
      let(:tenancy) { persist_new_tenancy }
      before { subject.assign_user(tenancy_ref: tenancy.tenancy_ref, user_id: assignee_id) }

      it 'should return the user\'s case' do
        expect(assigned_tenancies).to include(tenancy_ref: tenancy.tenancy_ref)
      end
    end

    context 'and many users have assigned cases' do
      let(:user_tenancy) { persist_new_tenancy }
      let(:other_assignee_id) { 1234 }

      before do
        subject.assign_user(tenancy_ref: user_tenancy.tenancy_ref, user_id: assignee_id)
        subject.assign_user(tenancy_ref: persist_new_tenancy.tenancy_ref, user_id: other_assignee_id)
        subject.assign_user(tenancy_ref: persist_new_tenancy.tenancy_ref, user_id: other_assignee_id)
      end

      it 'should only return the user\'s cases' do
        expect(assigned_tenancies).to eq([{
          tenancy_ref: user_tenancy.tenancy_ref
        }])
      end
    end

    context 'when auto assigning users to cases' do
      let!(:user1) { Hackney::Income::Models::User.create!(name: Faker::Name.name, role: :credit_controller) }
      let!(:user2) { Hackney::Income::Models::User.create!(name: Faker::Name.name, role: :credit_controller) }
      let!(:user3) { Hackney::Income::Models::User.create!(name: Faker::Name.name, role: :base_user) }

      let!(:unassigned_green) { create_assigned_tenancy_model(band: 'green', user: nil) }
      let!(:second_unassigned_green) { create_assigned_tenancy_model(band: 'green', user: nil) }
      let!(:unassigned_amber) { create_assigned_tenancy_model(band: 'amber', user: nil) }
      let!(:second_unassigned_amber) { create_assigned_tenancy_model(band: 'amber', user: nil) }
      let!(:unassigned_red) { create_assigned_tenancy_model(band: 'red', user: nil) }
      let!(:unassigned_case) { create_assigned_tenancy_model(band: 'error', user: nil) }

      context 'when no cases have been assigned' do
        it 'should assign to the first eligible user in the list' do
          expect(subject.assign_to_next_available_user(tenancy: unassigned_green)).to eq(user1.id)
          expect(unassigned_green.assigned_user).to eq(user1)
        end
      end

      context 'assigning a case which has a band that has a clear next user' do
        it 'should assign it to the user who is next able to take on a green case' do
          2.times { create_assigned_tenancy_model(band: 'green', user: user1) }
          1.times { create_assigned_tenancy_model(band: 'green', user: user2) }

          expect(subject.assign_to_next_available_user(tenancy: second_unassigned_green)).to eq(user2.id)
          expect(second_unassigned_green.assigned_user).to eq(user2)
        end

        it 'should assign it to the user at the top of the list if there is no clear choice' do
          1.times { create_assigned_tenancy_model(band: 'amber', user: user1) }
          1.times { create_assigned_tenancy_model(band: 'amber', user: user2) }

          expect(subject.assign_to_next_available_user(tenancy: unassigned_amber)).to eq(user1.id)
          expect(unassigned_amber.assigned_user).to eq(user1)

          expect(subject.assign_to_next_available_user(tenancy: second_unassigned_amber)).to eq(user2.id)
          expect(second_unassigned_amber.assigned_user).to eq(user2)
        end

        it 'should behave the same way for each band' do
          2.times { create_assigned_tenancy_model(band: 'red', user: user1) }
          1.times { create_assigned_tenancy_model(band: 'red', user: user2) }

          expect(subject.assign_to_next_available_user(tenancy: unassigned_red)).to eq(user2.id)
          expect(unassigned_red.assigned_user).to eq(user2)
        end
      end

      it 'should not assign if the band cannot be matched' do
        expect(subject.assign_to_next_available_user(tenancy: unassigned_case)).to be_nil
        expect(unassigned_case.assigned_user).to be_nil
      end
    end

    context 'when assigning several cases' do
      context 'and they are all in the same band' do
        it 'should assign them evenly to eligible users' do
          user_a, user_b, user_c, user_d, user_e = Array.new(5) { create(:user, :credit_controller) }
          user_f = create(:user)
          user_g = create(:user, :legal_case_worker)

          tenancy_a, tenancy_b, tenancy_c, tenancy_d, tenancy_e, tenancy_f = Array.new(6) { create(:case_priority, :red) }
          tenancy_g, tenancy_h, tenancy_i = Array.new(3) { create(:case_priority) }

          subject.assign_to_next_available_user(tenancy: tenancy_a)
          subject.assign_to_next_available_user(tenancy: tenancy_b)
          subject.assign_to_next_available_user(tenancy: tenancy_c)
          subject.assign_to_next_available_user(tenancy: tenancy_d)
          subject.assign_to_next_available_user(tenancy: tenancy_e)
          subject.assign_to_next_available_user(tenancy: tenancy_f)
          subject.assign_to_next_available_user(tenancy: tenancy_g)
          subject.assign_to_next_available_user(tenancy: tenancy_h)
          subject.assign_to_next_available_user(tenancy: tenancy_i)

          expect(user_a.case_priorities.count).to eq(3)
          expect(user_b.case_priorities.count).to eq(2)
          expect(user_c.case_priorities.count).to eq(2)
          expect(user_d.case_priorities.count).to eq(1)
          expect(user_e.case_priorities.count).to eq(1)
          expect(user_f.case_priorities.count).to eq(0)
          expect(user_g.case_priorities.count).to eq(0)
        end
      end
    end
  end

  def persist_new_tenancy
    tenancy = create_tenancy_model
    gateway_model.create!(tenancy_ref: tenancy.tenancy_ref)
  end

  def create_assigned_tenancy_model(band:, user:)
    gateway_model.create!(
      tenancy_ref: Faker::Lorem.characters(5),
      priority_band: band,
      priority_score: Faker::Lorem.characters(5),
      assigned_user: user
    )
  end
end
