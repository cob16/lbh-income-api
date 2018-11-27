# frozen_string_literal: true

require 'rails_helper'

describe TenanciesController, type: :controller do
  let(:paused_parms) do
    {
      tenancy_ref: Faker::Lorem.characters(8),
      is_paused_until: Faker::Date.forward(23).to_s,
      pause_reason: Faker::Lorem.sentence,
      pause_comment: Faker::Lorem.paragraph
    }
  end
  let(:params2) do
    {
      tenancy_ref: Faker::Lorem.characters(8),
      is_paused_until: Faker::Date.backward(23).to_s,
      pause_reason: Faker::Lorem.sentence,
      pause_comment: Faker::Lorem.paragraph
    }
  end

  before do
    stub_const('Hackney::Income::SqlPauseTenancyGateway', StubSqlPauseTenancyGateway)
  end

  it 'should be accessible from /' do
    assert_generates '/api/v1/tenancies/1234', controller: 'tenancies', action: 'update', tenancy_ref: 1234
  end

  context 'when receiving valid params' do
    it 'should pass the correct params to the use case' do
      expect_any_instance_of(Hackney::Income::SetTenancyPausedStatus).to receive(:execute).with(
        tenancy_ref: paused_parms.fetch(:tenancy_ref),
        until_date: paused_parms.fetch(:is_paused_until),
        pause_reason: paused_parms.fetch(:pause_reason),
        pause_comment: paused_parms.fetch(:pause_comment)
      ).and_call_original

      patch :update, params: paused_parms

      expect(response.status).to eq(204)
    end

    it 'should return a 200 response' do
      expect_any_instance_of(Hackney::Income::SetTenancyPausedStatus).to receive(:execute).with(
        tenancy_ref: params2.fetch(:tenancy_ref),
        until_date: params2.fetch(:is_paused_until).to_s,
        pause_reason: params2.fetch(:pause_reason),
        pause_comment: params2.fetch(:pause_comment)
      ).and_call_original

      patch :update, params: params2

      expect(response.status).to eq(204)
    end
  end

  context 'when receiving a tenancy id that does not exist' do
    before do
      stub_const('Hackney::Income::SetTenancyPausedStatus', StubSetUnknownTenancyPausedStatus)
    end

    it 'should return an exception detailing the unknown tenancy ref' do
      expect do
        patch :update, params: paused_parms
      end.to raise_error.with_message(
        /#{paused_parms.fetch(:tenancy_ref)}/
      )
    end
  end

  context 'when receiving a request missing params' do
    it 'should return a 400 - bad request' do
      assert_incomplete_params(
        tenancy_ref: Faker::Lorem.characters(8)
      )
    end
  end

  def assert_incomplete_params(params_hash)
    expect do
      patch :update, params: params_hash
    end.to raise_error ActionController::ParameterMissing
  end
end

class StubSetUnknownTenancyPausedStatus
  def initialize(gateway:); end

  def execute(tenancy_ref:, until_date:, pause_reason:, pause_comment:)
    raise "Raised on #{tenancy_ref}"
  end
end

class StubSqlPauseTenancyGateway
  def set_paused_until(tenancy_ref:, until_date:, pause_reason:, pause_comment:); end
end
