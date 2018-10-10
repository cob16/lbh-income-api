require 'rails_helper'

describe Hackney::Income::SetTenancyPausedStatus do
  subject { described_class.new(gateway: PauseGatewayDouble.new) }
  let(:tenancy_ref) { Faker::Lorem.characters(8) }

  context 'setting the pause status for a case' do
    context 'when the operation is successful' do
      it 'should pass the required params to the gateway' do
        expect_any_instance_of(PauseGatewayDouble).to receive(:set_paused_status)
          .with(tenancy_ref: tenancy_ref, status: true)

        subject.execute(tenancy_ref: tenancy_ref, status: true)
      end
    end

    context 'when the operation is unsuccessful' do
      subject { described_class.new(gateway: PauseGatewayDouble.new(true)) }

      it 'should not catch the exception raised' do
        expect { subject.execute(tenancy_ref: tenancy_ref, status: true) }.to raise_error
          .with_message(/#{tenancy_ref}/)
      end
    end
  end
end

class PauseGatewayDouble
  def initialize(raise_exc = false)
    @raise = raise_exc
  end

  def set_paused_status(tenancy_ref:, status:)
    raise "Raised on #{tenancy_ref}" if @raise
  end
end
