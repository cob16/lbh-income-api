require 'rails_helper'

describe Hackney::Income::TenancyPrioritiser::UniversalHousingCriteria do
  subject(:criteria) { described_class.for_tenancy(tenancy_ref) }

  let(:tenancy_ref) { '000015/01' }
  let(:current_balance) { Faker::Number.decimal.to_f }

  before do
    Hackney::UniversalHousing::Models::Tenagree.create(tag_ref: tenancy_ref, cur_bal: current_balance)
  end

  it { is_expected.to be_instance_of(described_class) }

  describe '#balance' do
    subject { criteria.balance }

    it 'should return the current balance of a tenancy' do
      expect(subject).to eq(current_balance)
    end
  end

  describe '#days_in_arrears' do
    subject { criteria.days_in_arrears }

    context 'when the tenancy is not in arrears' do
      let(:current_balance) { -50.00 }

      it { is_expected.to be_zero }
    end

    context 'when the tenancy has paid off their balance perfectly' do
      let(:current_balance) { 0.0 }

      it { is_expected.to be_zero }
    end

    context 'when the tenancy has been in arrears for a week' do
      let(:current_balance) { 100.00 }

      before do
        Hackney::UniversalHousing::Models::Rtrans.create(tag_ref: tenancy_ref, real_value: 75.0, post_date: Date.today - 3.days, batchid: rand(1..100000))
        Hackney::UniversalHousing::Models::Rtrans.create(tag_ref: tenancy_ref, real_value: 50.0, post_date: Date.today - 7.days, batchid: rand(1..100000))
      end

      it 'should return the difference between now and the first date it was in arrears' do
        expect(subject).to eq(7)
      end
    end

    context 'when the tenancy has been in arrears for two weeks' do
      let(:current_balance) { 100.00 }

      before do
        Hackney::UniversalHousing::Models::Rtrans.create(tag_ref: tenancy_ref, real_value: 75.0, post_date: Date.today - 7.days, batchid: rand(1..100000))
        Hackney::UniversalHousing::Models::Rtrans.create(tag_ref: tenancy_ref, real_value: 25.0, post_date: Date.today - 14.days, batchid: rand(1..100000))
      end

      it 'should return the difference between now and the first date it was in arrears' do
        expect(subject).to eq(14)
      end
    end

    context 'when the tenancy has always been in arrears' do
      let(:current_balance) { 100.00 }

      before do
        Hackney::UniversalHousing::Models::Rtrans.create(tag_ref: tenancy_ref, real_value: 10.0, post_date: Date.today - 2.days, batchid: rand(1..100000))
        Hackney::UniversalHousing::Models::Rtrans.create(tag_ref: tenancy_ref, real_value: 10.0, post_date: Date.today - 30.days, batchid: rand(1..100000))
      end

      it 'should return the first date' do
        expect(subject).to eq(30)
      end
    end
  end

  describe '#days_since_last_payment' do
    subject { criteria.days_since_last_payment }

    context 'when the tenant has never paid' do
      it { is_expected.to be_nil }
    end

    context 'when the tenant paid two days ago' do
      before do
        Hackney::UniversalHousing::Models::Rtrans.create(tag_ref: tenancy_ref, trans_type: 'RPY', post_date: Date.today - 2.days, batchid: rand(1..100000))
      end

      it { is_expected.to eq(2) }
    end

    context 'when the tenant paid five days ago, and rent was issued two days ago' do
      before do
        Hackney::UniversalHousing::Models::Rtrans.create(tag_ref: tenancy_ref, trans_type: 'RNT', post_date: Date.today - 2.days, batchid: rand(1..100000))
        Hackney::UniversalHousing::Models::Rtrans.create(tag_ref: tenancy_ref, trans_type: 'RPY', post_date: Date.today - 5.days, batchid: rand(1..100000))
      end

      it { is_expected.to eq(5) }
    end
  end

  describe '#active_agreement?' do
    subject { criteria.active_agreement? }

    context 'when the tenant has no arrears agreements' do
      it { is_expected.to be(false) }
    end

    context 'when the tenant has an active arrears agreement' do
      before do
        Hackney::UniversalHousing::Models::Arag.create(tag_ref: tenancy_ref, arag_status: '200')
      end

      it { is_expected.to be(true) }
    end

    context 'when the tenant has a breached arrears agreement' do
      before do
        Hackney::UniversalHousing::Models::Arag.create(tag_ref: tenancy_ref, arag_status: '300')
      end

      it { is_expected.to be(false) }
    end
  end

  describe '#number_of_broken_agreements' do
    subject { criteria.number_of_broken_agreements }

    context 'when the tenant has no arrears agreements' do
      it { is_expected.to be_zero }
    end

    context 'when the tenant has an active arrears agreement' do
      before do
        Hackney::UniversalHousing::Models::Arag.create(tag_ref: tenancy_ref, arag_status: '200')
      end

      it { is_expected.to be_zero }
    end

    context 'when the tenant has a number of broken arrears agreement' do
      let(:broken_agreements_count) { Faker::Number.number(2).to_i }

      before do
        broken_agreements_count.times do
          Hackney::UniversalHousing::Models::Arag.create(arag_ref: Faker::IDNumber.valid, tag_ref: tenancy_ref, arag_status: '300')
        end
      end

      it 'should be equal the number of broken agreements' do
        expect(subject).to eq(broken_agreements_count)
      end
    end
  end

  describe 'nosp_served?' do
    subject { criteria.nosp_served? }

    context 'when a tenant does not have a nosp' do
      it { is_expected.to be(false) }
    end

    context 'when a tenant had a nosp served recently' do
      before do
        Hackney::UniversalHousing::Models::Araction.create(tag_ref: tenancy_ref, action_code: 'NTS', action_date: Date.today)
      end

      it { is_expected.to be(true) }
    end

    context 'when a tenant had a nosp served a year ago' do
      before do
        Hackney::UniversalHousing::Models::Araction.create(tag_ref: tenancy_ref, action_code: 'NTS', action_date: Date.today - 1.year)
      end

      it { is_expected.to be(true) }
    end

    context 'when a tenant had a nosp served over a year ago' do
      before do
        Hackney::UniversalHousing::Models::Araction.create(tag_ref: tenancy_ref, action_code: 'NTS', action_date: Date.today - 1.year - 1.day)
      end

      it { is_expected.to be(false) }
    end
  end

  describe 'active_nosp?' do
    subject { criteria.active_nosp? }

    context 'when a tenant does not have a nosp' do
      it { is_expected.to be(false) }
    end

    context 'when a tenant had a nosp served recently' do
      before do
        Hackney::UniversalHousing::Models::Araction.create(tag_ref: tenancy_ref, action_code: 'NTS', action_date: Date.today)
      end

      it { is_expected.to be(true) }
    end

    context 'when a tenant had a nosp served a month ago' do
      before do
        Hackney::UniversalHousing::Models::Araction.create(tag_ref: tenancy_ref, action_code: 'NTS', action_date: Date.today - 1.month)
      end

      it { is_expected.to be(true) }
    end

    context 'when a tenant had a nosp served over a month ago' do
      before do
        Hackney::UniversalHousing::Models::Araction.create(tag_ref: tenancy_ref, action_code: 'NTS', action_date: Date.today - 1.month - 1.day)
      end

      it { is_expected.to be(false) }
    end
  end

  describe '#payment_amount_delta' do
    subject { criteria.payment_amount_delta }

    context 'when a tenant has made no payments' do
      it { is_expected.to be(nil) }
    end

    context 'when a tenant has made one payment' do
      before do
        Hackney::UniversalHousing::Models::Rtrans.create(tag_ref: tenancy_ref, trans_type: 'RPY', batchid: rand(1..100000))
      end

      it { is_expected.to be(nil) }
    end

    context 'when a tenant has made two payments' do
      before do
        Hackney::UniversalHousing::Models::Rtrans.create(tag_ref: tenancy_ref, trans_type: 'RPY', batchid: rand(1..100000))
        Hackney::UniversalHousing::Models::Rtrans.create(tag_ref: tenancy_ref, trans_type: 'RPY', batchid: rand(1..100000))
      end

      it { is_expected.to be(nil) }
    end

    context 'when a tenant has made three payments of fluctuating amounts' do
      before do
        Hackney::UniversalHousing::Models::Rtrans.create(tag_ref: tenancy_ref, trans_type: 'RPY', real_value: -25.0, batchid: rand(1..100000))
        Hackney::UniversalHousing::Models::Rtrans.create(tag_ref: tenancy_ref, trans_type: 'RPY', real_value: -75.0, batchid: rand(1..100000))
        Hackney::UniversalHousing::Models::Rtrans.create(tag_ref: tenancy_ref, trans_type: 'RPY', real_value: -75.0, batchid: rand(1..100000))
      end

      it 'should return the delta between payments' do
        expect(subject).to eq(50.0)
      end
    end

    context 'when a tenant has made three payments of the same amount' do
      before do
        Hackney::UniversalHousing::Models::Rtrans.create(tag_ref: tenancy_ref, trans_type: 'RPY', real_value: -50.0, batchid: rand(1..100000))
        Hackney::UniversalHousing::Models::Rtrans.create(tag_ref: tenancy_ref, trans_type: 'RPY', real_value: -50.0, batchid: rand(1..100000))
        Hackney::UniversalHousing::Models::Rtrans.create(tag_ref: tenancy_ref, trans_type: 'RPY', real_value: -50.0, batchid: rand(1..100000))
      end

      it 'should return the delta between payments' do
        expect(subject).to eq(0.0)
      end
    end
  end

  describe '#payment_date_delta' do
    subject { criteria.payment_date_delta }

    context 'when a tenant has made no payments' do
      it { is_expected.to be(nil) }
    end

    context 'when a tenant has made one payment' do
      before do
        Hackney::UniversalHousing::Models::Rtrans.create(tag_ref: tenancy_ref, trans_type: 'RPY', batchid: rand(1..100000))
      end

      it { is_expected.to be(nil) }
    end

    context 'when a tenant has made two payments' do
      before do
        Hackney::UniversalHousing::Models::Rtrans.create(tag_ref: tenancy_ref, trans_type: 'RPY', batchid: rand(1..100000))
        Hackney::UniversalHousing::Models::Rtrans.create(tag_ref: tenancy_ref, trans_type: 'RPY', batchid: rand(1..100000))
      end

      it { is_expected.to be(nil) }
    end

    context 'when a tenant has made three payments on fluctuating days' do
      before do
        Hackney::UniversalHousing::Models::Rtrans.create(tag_ref: tenancy_ref, trans_type: 'RPY', post_date: Date.today, batchid: rand(1..100000))
        Hackney::UniversalHousing::Models::Rtrans.create(tag_ref: tenancy_ref, trans_type: 'RPY', post_date: Date.today - 15.days, batchid: rand(1..100000))
        Hackney::UniversalHousing::Models::Rtrans.create(tag_ref: tenancy_ref, trans_type: 'RPY', post_date: Date.today - 25.days, batchid: rand(1..100000))
      end

      it 'should return the delta between payment dates' do
        expect(subject).to eq(5)
      end
    end

    context 'when a tenant has made three payments an equal amount of time apart' do
      before do
        Hackney::UniversalHousing::Models::Rtrans.create(tag_ref: tenancy_ref, trans_type: 'RPY', post_date: Date.today - 10.days, batchid: rand(1..100000))
        Hackney::UniversalHousing::Models::Rtrans.create(tag_ref: tenancy_ref, trans_type: 'RPY', post_date: Date.today - 10.days, batchid: rand(1..100000))
        Hackney::UniversalHousing::Models::Rtrans.create(tag_ref: tenancy_ref, trans_type: 'RPY', post_date: Date.today - 10.days, batchid: rand(1..100000))
      end

      it 'should return the delta between payment dates' do
        expect(subject).to be_zero
      end
    end
  end
end
