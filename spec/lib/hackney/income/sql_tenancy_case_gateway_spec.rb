require 'rails_helper'

describe Hackney::Income::SqlTenancyCaseGateway do
  subject { described_class.new }

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
        expect(Hackney::Income::Models::Tenancy.exists?(tenancy_ref: tenancy.tenancy_ref)).to be_truthy
      end
    end
  end

  context 'when persisting a tenancy which already exists in the database' do
    let(:tenancy) { create_tenancy_model }
    let(:existing_tenancy_record) do
      Hackney::Income::Models::Tenancy.create!(tenancy_ref: tenancy.tenancy_ref)
    end

    before do
      existing_tenancy_record
      subject.persist(tenancies: [tenancy])
    end

    it 'should not create a new record' do
      expect(Hackney::Income::Models::Tenancy.count).to eq(1)
    end
  end

  context 'when assigning a user to a case' do
    let!(:tenancy_ref) { Faker::Number.number(6) }
    let!(:tenancy) { Hackney::Income::Models::Tenancy.create(tenancy_ref: tenancy_ref) }
    let!(:user) { Hackney::Income::Models::User.create }

    it 'should assign the user' do
      subject.assign_user(tenancy_ref: tenancy_ref, user_id: user.id)
      expect(tenancy.reload).to have_attributes(
        assigned_user: user
      )
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
      let!(:user1) { Hackney::Income::Models::User.create!(name: Faker::Name.name) }
      let!(:user2) { Hackney::Income::Models::User.create!(name: Faker::Name.name) }

      let!(:unassigned_green) { create_assigned_tenancy_model(band: 'green', user: nil) }
      let!(:second_unassigned_green) { create_assigned_tenancy_model(band: 'green', user: nil) }
      let!(:unassigned_amber) { create_assigned_tenancy_model(band: 'amber', user: nil) }
      let!(:second_unassigned_amber) { create_assigned_tenancy_model(band: 'amber', user: nil) }
      let!(:unassigned_red) { create_assigned_tenancy_model(band: 'red', user: nil) }
      let!(:unassigned_case) { create_assigned_tenancy_model(band: 'error', user: nil) }

      context 'when no cases have been assigned' do
        it 'should assign to the first user in the list' do
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
        it 'should assign them evenly' do
          user_a = Hackney::Income::Models::User.create!
          user_b = Hackney::Income::Models::User.create!
          user_c = Hackney::Income::Models::User.create!
          user_d = Hackney::Income::Models::User.create!
          user_e = Hackney::Income::Models::User.create!

          tenancy_a = Hackney::Income::Models::Tenancy.create!(priority_band: :red)
          tenancy_b = Hackney::Income::Models::Tenancy.create!(priority_band: :red)
          tenancy_c = Hackney::Income::Models::Tenancy.create!(priority_band: :red)
          tenancy_d = Hackney::Income::Models::Tenancy.create!(priority_band: :red)
          tenancy_e = Hackney::Income::Models::Tenancy.create!(priority_band: :red)

          subject.assign_to_next_available_user(tenancy: tenancy_a)
          subject.assign_to_next_available_user(tenancy: tenancy_b)
          subject.assign_to_next_available_user(tenancy: tenancy_c)
          subject.assign_to_next_available_user(tenancy: tenancy_d)
          subject.assign_to_next_available_user(tenancy: tenancy_e)

          expect(user_a.tenancies.count).to eq(1)
          expect(user_b.tenancies.count).to eq(1)
          expect(user_c.tenancies.count).to eq(1)
          expect(user_d.tenancies.count).to eq(1)
          expect(user_e.tenancies.count).to eq(1)
        end
      end
    end
  end

  def persist_new_tenancy
    tenancy = create_tenancy_model
    Hackney::Income::Models::Tenancy.create!(tenancy_ref: tenancy.tenancy_ref)
  end

  def create_tenancy_model
    Hackney::Income::Models::Tenancy.new.tap do |t|
      t.tenancy_ref = Faker::Lorem.characters(5)
      t.priority_band = Faker::Lorem.characters(5)
      t.priority_score = Faker::Lorem.characters(5)
    end
  end

  def create_assigned_tenancy_model(band:, user:)
    Hackney::Income::Models::Tenancy.create!(
      tenancy_ref: Faker::Lorem.characters(5),
      priority_band: band,
      priority_score: Faker::Lorem.characters(5),
      assigned_user: user
    )
  end
end
