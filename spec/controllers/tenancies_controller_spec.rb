require 'rails_helper'

describe TenanciesController, type: :controller do
  let(:params1) do
    {
      tenancy_ref: Faker::Lorem.characters(8),
      is_paused: true
    }
  end
  let(:params2) do
    {
      tenancy_ref: Faker::Lorem.characters(8),
      is_paused: false
    }
  end

  before do
    stub_const('Hackney::Income::SetTenancyPausedStatus', StubSetTenancyPausedStatus)
  end

  context 'when receiving valid params' do
    it 'should pass the correct params to the use case' do
      expect_any_instance_of(Hackney::Income::SetTenancyPausedStatus).to receive(:execute).with(
        tenancy_ref: params1.fetch(:tenancy_ref),
        status: params1.fetch(:is_paused).to_s
      ).and_return(nil)

      patch :update, params: params1
    end

    it 'should return a 200 response' do
      expect_any_instance_of(Hackney::Income::SetTenancyPausedStatus).to receive(:execute).with(
        tenancy_ref: params2.fetch(:tenancy_ref),
        status: params2.fetch(:is_paused).to_s
      ).and_return(nil)

      patch :update, params: params2

      expect(response.status).to eq(204)
    end
  end

  context 'when receiving a tenancy id that does not exist' do
    before do
      stub_const('Hackney::Income::SetTenancyPausedStatus', StubSetUnknownTenancyPausedStatus)
    end

    it 'should return an exception detailing the unknown tenancy ref' do
      expect {
        patch :update, params: params1
      }.to raise_error.with_message(
        /#{params1.fetch(:tenancy_ref)}/
      )
    end
  end

  context 'when receiving a request missing params' do
    it 'should return a 400 - bad request' do
      assert_incomplete_params({
        tenancy_ref: Faker::Lorem.characters(8)
      })
    end
  end

  def assert_incomplete_params(params_hash)
    expect {
      patch :update, params: params_hash
    }.to raise_error ActionController::ParameterMissing
  end
end

class StubSetUnknownTenancyPausedStatus
  def initialize(gateway:); end

  def execute(tenancy_ref:, status:)
    raise "Raised on #{tenancy_ref}"
  end
end

class StubSetTenancyPausedStatus
  def initialize(gateway:); end
  def execute(tenancy_ref:, status:); end
end
