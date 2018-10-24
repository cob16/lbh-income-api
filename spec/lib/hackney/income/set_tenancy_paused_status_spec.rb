require 'rails_helper'

describe Hackney::Income::SetTenancyPausedStatus do
  subject { described_class.new(gateway: PauseGatewayDouble.new) }
  let(:tenancy_ref) { Faker::Lorem.characters(8) }
  let(:future_date) { Faker::Date.forward(23).to_s }

  context 'setting the pause status for a case' do
    context 'when the operation is successful' do
      it 'should pass the required params to the gateway' do
        expect_any_instance_of(PauseGatewayDouble).to receive(:set_paused_until)
          .with(tenancy_ref: tenancy_ref, until_date: future_date)

        subject.execute(tenancy_ref: tenancy_ref, until_date: future_date)
      end
    end

    context 'when the operation is unsuccessful' do
      subject { described_class.new(gateway: PauseGatewayDouble.new(true)) }

      it 'should not catch the exception raised' do
        expect { subject.execute(tenancy_ref: tenancy_ref, until_date: future_date) }.to raise_error
          .with_message(/#{tenancy_ref}/)
      end
      it 'should not catch the exception raised' do
        expect { subject.execute(tenancy_ref: tenancy_ref, until_date: 'future_date') }.to raise_error
          .with_message(/invalid date/)
      end
    end
  end
end

class PauseGatewayDouble
  def initialize(raise_exc = false)
    @raise = raise_exc
  end

  def set_paused_until(tenancy_ref:, until_date:)
    DateTime.parse(until_date)
    raise "Raised on #{tenancy_ref}" if @raise
    # raise "Raised on #{tenancy_ref}" if @raise
  end
end
