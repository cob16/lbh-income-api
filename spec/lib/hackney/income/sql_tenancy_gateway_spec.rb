require 'rails_helper'

describe Hackney::Income::SqlTenancyGateway do
  subject { described_class.new }

  let(:tenancy_1) { create_tenancy_model }
  let(:invalid_string) { SecureRandom.uuid }
  let(:gateway_model) { described_class::GatewayModel }

  before do
    tenancy_1.save
  end

  context 'when getting a tenancy' do
    it 'gets tenancy' do
      tenancy_pause = subject.get_tenancy(
        tenancy_ref: tenancy_1.tenancy_ref
      )

      expect(tenancy_pause).to eq(tenancy_1)
    end

    it 'raises an error when tenancy ref is not found' do
      expect {
        subject.get_tenancy(tenancy_ref: 'not_a_valid_ref')
      }.to raise_error(Hackney::Income::SqlTenancyGateway::TenancyNotFoundError)
    end
  end
end
