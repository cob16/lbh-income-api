require 'rails_helper'

describe Hackney::Income::SqlPauseTenancyGateway do
  let(:tenancy_1) { create_tenancy_model }

  subject { described_class.new }

  before do
    tenancy_1.save
  end

  context 'set pause status' do
    context ' when the tenancy does not exist' do
      it 'should raise an exception containing the tenancy ref' do
        expect { subject.set_paused_status(tenancy_ref: 'does_not_exist', status: true) }
          .to raise_error
          .with_message(/does_not_exist/)
      end
    end

    it 'should default to unpaused' do
      expect(tenancy_1.paused?).to be(false)
    end

    it 'should update with the given status' do
      subject.set_paused_status(tenancy_ref: tenancy_1.tenancy_ref, status: true)

      expect(Hackney::Income::Models::Tenancy.find_by(tenancy_ref: tenancy_1.tenancy_ref).paused?).to be(true)
    end
  end
end
