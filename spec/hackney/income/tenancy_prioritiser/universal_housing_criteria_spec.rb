require 'rails_helper'

describe Hackney::Income::TenancyPrioritiser::UniversalHousingCriteria do
  subject { described_class.for_tenancy(tenancy_ref) }

  let(:tenancy_ref) { '000015/01' }
  let(:current_balance) { Faker::Number.decimal.to_f }

  before do
    Hackney::UniversalHousing::Models::Tenagree.create(tag_ref: tenancy_ref, cur_bal: current_balance)
  end

  it 'should be a criteria object' do
    expect(subject).to be_instance_of(described_class)
  end

  describe '#balance' do
    it 'should return the current balance of a tenancy' do
      expect(subject.balance).to eq(current_balance)
    end
  end

  describe '#days_in_arrears' do
    context 'when the tenancy is not in arrears' do
      let(:current_balance) { -50.00 }

      it 'should return zero' do
        expect(subject.days_in_arrears).to be_zero
      end
    end

    context 'when the tenancy has paid off their balance perfectly' do
      let(:current_balance) { 0.0 }

      it 'should return zero' do
        expect(subject.days_in_arrears).to be_zero
      end
    end

    context 'when the tenancy has been in arrears for a week' do
      let(:current_balance) { 100.00 }

      before do
        Hackney::UniversalHousing::Models::Rtrans.create(tag_ref: tenancy_ref, real_value: 75.0, post_date: Date.today - 3.days, batchid: rand(1..100000))
        Hackney::UniversalHousing::Models::Rtrans.create(tag_ref: tenancy_ref, real_value: 50.0, post_date: Date.today - 7.days, batchid: rand(1..100000))
      end

      it 'should return the difference between now and the first date it was in arrears' do
        expect(subject.days_in_arrears).to eq(7)
      end
    end

    context 'when the tenancy has been in arrears for two weeks' do
      let(:current_balance) { 100.00 }

      before do
        Hackney::UniversalHousing::Models::Rtrans.create(tag_ref: tenancy_ref, real_value: 75.0, post_date: Date.today - 7.days, batchid: rand(1..100000))
        Hackney::UniversalHousing::Models::Rtrans.create(tag_ref: tenancy_ref, real_value: 25.0, post_date: Date.today - 14.days, batchid: rand(1..100000))
      end

      it 'should return the difference between now and the first date it was in arrears' do
        expect(subject.days_in_arrears).to eq(14)
      end
    end

    context 'when the tenancy has always been in arrears' do
      let(:current_balance) { 100.00 }

      before do
        Hackney::UniversalHousing::Models::Rtrans.create(tag_ref: tenancy_ref, real_value: 10.0, post_date: Date.today - 2.days, batchid: rand(1..100000))
        Hackney::UniversalHousing::Models::Rtrans.create(tag_ref: tenancy_ref, real_value: 10.0, post_date: Date.today - 30.days, batchid: rand(1..100000))
      end

      it 'should return the first date' do
        expect(subject.days_in_arrears).to eq(30)
      end
    end
  end
end
