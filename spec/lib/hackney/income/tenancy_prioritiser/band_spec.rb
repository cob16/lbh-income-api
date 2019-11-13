require 'rails_helper'

describe Hackney::Income::TenancyPrioritiser::Band do
  subject { band_assigner.execute }

  let(:criteria) { Stubs::StubCriteria.new(attributes) }
  let(:band_assigner) { described_class.new(criteria) }

  let(:attributes) do
    {
      weekly_rent: weekly_rent,
      balance: balance,
      nosp_served: nosp_served,
      last_communication_date: last_communication_date,
      last_communication_action: last_communication_action,
      days_in_arrears: days_in_arrears,
      days_since_last_payment: days_since_last_payment,
      active_agreement: active_agreement,
      number_of_broken_agreements: number_of_broken_agreements,
      broken_court_order: broken_court_order,
      payment_date_delta: payment_date_delta,
      payment_amount_delta: payment_amount_delta
    }
  end

  let(:weekly_rent) { 5.0 }
  let(:balance) { 5.00 }
  let(:nosp_served) { false }
  let(:last_communication_date) { nil }
  let(:last_communication_action) { nil }
  let(:days_in_arrears) { nil }
  let(:broken_court_order) { nil }
  let(:number_of_broken_agreements) { nil }
  let(:days_since_last_payment) { nil }
  let(:payment_date_delta) { nil }
  let(:payment_amount_delta) { nil }
  let(:active_agreement) { nil }

  context 'when maintaining an agreement' do
    let(:balance) { 500.00 }
    let(:days_in_arrears) { 125 }
    let(:days_since_last_payment) { 6 }
    let(:active_agreement) { true }

    it 'will assign green while an active agreement is maintained regardless of other factors' do
      expect(subject).to eq(:green)
    end
  end

  context 'when assigning a tenancy to the red band' do
    context 'with balance is greater than £1050' do
      let(:balance) { 1050 }

      it 'happens' do
        expect(subject).to eq(:red)
      end
    end

    context 'when a court ordered repayment agreement is broken' do
      let(:broken_court_order) { true }

      it 'happens' do
        expect(subject).to eq(:red)
      end
    end

    # FIXME: I think we should probably defensively filter agreements > 3 years old
    context 'when more than two agreements have been breached in the last three years and there is no live agreement' do
      let(:number_of_broken_agreements) { 3 }
      let(:active_agreement) { false }

      it 'happens' do
        expect(subject).to eq(:red)
      end
    end

    context 'when debt age is greater than 30 weeks' do
      let(:days_in_arrears) { 31 * 7 }

      it 'happens' do
        expect(subject).to eq(:red)
      end
    end

    context 'when a valid nosp is present and no payment has been received in 28 days' do
      let(:nosp_served) { true }
      let(:days_since_last_payment) { 29 }

      it 'happens' do
        expect(subject).to eq(:red)
      end
    end

    context 'when a valid nosp is present and no payment has ever been received' do
      let(:nosp_served) { true }
      let(:days_since_last_payment) { nil }

      it 'happens' do
        expect(subject).to eq(:red)
      end
    end

    context 'when payment pattern is erratic' do
      context 'with the payment date delta as nil' do
        let(:payment_date_delta) { nil }

        it 'will not factor this if the delta is nil, as there are too few payments to calculate' do
          expect(subject).to eq(:green)
        end
      end

      context 'with the payment date delta is greater than three' do
        let(:payment_date_delta) { 4 }

        it 'is assigned red ' do
          expect(subject).to eq(:red)
        end
      end

      context 'with the payment date delta is less than negative three' do
        let(:payment_date_delta) { -4 }

        it 'is assigned red' do
          expect(subject).to eq(:red)
        end
      end

      context 'with the payment amount delta is negative' do
        let(:payment_amount_delta) { 1 }

        it 'is assigned red' do
          expect(subject).to eq(:red)
        end
      end
    end

    context 'when assigning a tenancy to the amber band' do
      context 'when balance is greater than £350' do
        let(:balance) { 351 }

        it 'happens' do
          expect(subject).to eq(:amber)
        end
      end

      context 'when debt age is greater than 15 weeks' do
        let(:days_in_arrears) { 16 * 7 }

        it 'happens' do
          expect(subject).to eq(:amber)
        end
      end

      # FIXME: There's some missing business logic here - nosp can be present and you can be green
      # FIXME: what about when you are amber, have a nosp, make sporadic payments without an agreement
      context 'when a valid nosp was served within the last 28 days' do
        let(:nosp_served) { true }
        let(:days_since_last_payment) { 7 }

        it 'happens ' do
          expect(subject).to eq(:amber)
        end
      end

      context 'when previous agreements have been broken and there are no live agreements' do
        let(:number_of_broken_agreements) { 1 }

        it 'happens ' do
          expect(subject).to eq(:amber)
        end
      end
    end

    context 'when assigning a tenancy to the green band' do
      it 'is otherwise green' do
        expect(subject).to eq(:green)
      end
    end
  end
end
