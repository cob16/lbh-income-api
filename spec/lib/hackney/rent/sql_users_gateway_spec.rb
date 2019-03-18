require 'rails_helper'

describe Hackney::Rent::SqlUsersGateway do
  let(:gateway) { described_class.new }

  context 'when finding or creating a User' do
    subject do
      gateway.find_or_create_user(
        provider_uid: 'close-to-me',
        provider: 'universal',
        name: 'Robert Smith',
        email: 'exploding-boy@the-cure.com',
        first_name: 'Robert',
        last_name: 'Smith',
        provider_permissions: '12345.98765'
      )
    end

    context 'when this user does not exist' do
      before { subject }

      it 'creates a new User instance for that user' do
        expect(Hackney::Income::Models::User.first).to have_attributes(
          provider_uid: 'close-to-me',
          provider: 'universal',
          name: 'Robert Smith',
          email: 'exploding-boy@the-cure.com',
          first_name: 'Robert',
          last_name: 'Smith',
          provider_permissions: '12345.98765'
        )
      end
    end

    context 'when this user exists' do
      before do
        Hackney::Income::Models::User.create!(
          provider_uid: 'close-to-me',
          provider: 'universal',
          name: 'Robert Smith',
          email: 'old-email@the-cure.com',
          first_name: 'Robert',
          last_name: 'Smith',
          provider_permissions: '12345.98765'
        )

        subject
      end

      it 'does not create a duplicate user' do
        expect(Hackney::Income::Models::User.count).to eq(1)
      end

      it 'updates the record found' do
        expect(Hackney::Income::Models::User.first.email).to eq('exploding-boy@the-cure.com')
      end
    end

    it 'returns a hash representing the user' do
      expect(subject).to include(
        id: 1,
        name: 'Robert Smith'
      )
    end
  end

  context 'when finding a individual User' do
    subject do
      gateway.find_user(
        id: user.id
      )
    end

    context 'when this user does not exist' do
      let(:user) do
        Hackney::Income::Models::User.new(
          provider_uid: 'close-to-me',
          provider: 'universal',
          name: 'Robert Smith',
          email: 'old-email@the-cure.com',
          first_name: 'Robert',
          last_name: 'Smith',
          provider_permissions: '12345.98765'
        )
      end

      before do
        user.save!
      end

      it 'creates a new User instance for that user' do
        expect(subject).to eq(user)
      end
    end
  end
end
