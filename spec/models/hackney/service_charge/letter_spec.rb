require 'rails_helper'

describe Hackney::ServiceCharge::Letter do
  let(:letter_params) {
    {
      payment_ref: Faker::Number.number(4),
      lessee_full_name: Faker::Name.name,
      correspondence_address1: Faker::Address.street_address,
      correspondence_address2: Faker::Address.secondary_address,
      correspondence_address3: Faker::Address.city,
      correspondence_postcode: Faker::Address.zip_code,
      property_address: Faker::Address.street_address,
      total_collectable_arrears_balance: Faker::Number.number(3),
      money_judgement: Faker::Number.number(2),
      charging_order: Faker::Number.number(2),
      bal_dispute: Faker::Number.number(2)
    }
  }

  context 'when no errors are present' do
    let(:letter) { described_class.new(letter_params.merge(correspondence_address3: '')) }

    it { expect(letter.errors).to eq [] }
  end

  context 'when errors are present' do
    let(:letter) {
      described_class.new(letter_params.merge(
                            payment_ref: '',
                            lessee_full_name: '',
                            correspondence_address1: '',
                            correspondence_address2: '',
                            correspondence_address3: '',
                            correspondence_postcode: '',
                            property_address: '',
                            total_collectable_arrears_balance: 0,
                            international: true
                          ))
    }

    it {
      expect(letter.errors).to eq [
        { message: 'missing mandatory field', name: 'payment_ref' },
        { message: 'missing mandatory field', name: 'lessee_full_name' },
        { message: 'missing mandatory field', name: 'correspondence_address1' },
        { message: 'missing mandatory field', name: 'correspondence_address2' },
        { message: 'missing mandatory field', name: 'correspondence_postcode' },
        { message: 'missing mandatory field', name: 'property_address' },
        { message: 'international address', name: 'address' }
      ]
    }
  end

  context 'when reorganisation of the address is needed' do
    let(:letter) { described_class.new(letter_params.merge(correspondence_address1: '')) }

    it { expect(letter.correspondence_address1).to eq(letter_params[:correspondence_address2]) }

    it { expect(letter.correspondence_address2).to eq(letter_params[:correspondence_address3]) }
  end

  context 'when a money judgement and charging order exists' do
    let(:letter) { described_class.new(letter_params) }
    it 'subtract the money judgement and charging order from the total collectable balance' do
      balance = letter_params[:total_collectable_arrears_balance].to_i
      money_judgement = letter_params[:money_judgement].to_i
      charging_order = letter_params[:charging_order].to_i
      bal_dispute = letter_params[:bal_dispute].to_i
      expected_total_collectable_arrears_balance = format('%.2f', balance - (money_judgement + charging_order + bal_dispute))
      expect(letter.lba_balance).to eq(expected_total_collectable_arrears_balance)
    end
  end
end
