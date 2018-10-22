require 'rails_helper'

describe Hackney::Income::SqlPauseTenancyGateway do
  let(:tenancy_1) { create_tenancy_model }
  let(:future_date) { Faker::Date.forward(23).to_s }

  subject { described_class.new }

  before do
    tenancy_1.save
  end

  context 'set pause status' do
    context ' when the tenancy does not exist' do
      it 'should raise an exception containing the tenancy ref' do
        expect { subject.set_paused_until(tenancy_ref: 'does_not_exist', until_date: future_date) }
          .to raise_error
          .with_message(/does_not_exist/)
      end
    end

    it 'should default to unpaused' do
      expect(tenancy_1.is_paused?).to be(false)
    end

    it 'should update with the given an unpause date' do
      subject.set_paused_until(tenancy_ref: tenancy_1.tenancy_ref, until_date: future_date)

      expect(Hackney::Income::Models::Tenancy.find_by(tenancy_ref: tenancy_1.tenancy_ref).is_paused?).to be(true)
    end
  end

end
