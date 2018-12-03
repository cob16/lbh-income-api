# frozen_string_literal: true

require 'rails_helper'

describe TenanciesController, type: :controller do
  let(:paused_parms) do
    {
      user_id: Faker::Number.number(2),
      tenancy_ref: Faker::Lorem.characters(8),
      is_paused_until: Faker::Date.forward(23).to_s,
      pause_reason: Faker::Lorem.sentence,
      pause_comment: Faker::Lorem.paragraph,
      action_code: Faker::Internet.slug
    }
  end
  let(:params2) do
    {
      user_id: Faker::Number.number(2),
      tenancy_ref: Faker::Lorem.characters(8),
      is_paused_until: Faker::Date.backward(23).to_s,
      pause_reason: Faker::Lorem.sentence,
      pause_comment: Faker::Lorem.paragraph,
      action_code: Faker::Internet.slug
    }
  end

  let(:dummy_action_diary_usecase) { double(Hackney::Tenancy::AddActionDiaryEntry) }

  before do
    stub_const('Hackney::Income::SqlPauseTenancyGateway', StubSqlPauseTenancyGateway)
    stub_const('Hackney::Tenancy::AddActionDiaryEntry', dummy_action_diary_usecase)
    allow(dummy_action_diary_usecase).to receive(:new).and_return(dummy_action_diary_usecase)
    allow(dummy_action_diary_usecase).to receive(:execute)
  end

  it 'should be accessible from /' do
    assert_generates '/api/v1/tenancies/1234', controller: 'tenancies', action: 'update', tenancy_ref: 1234
  end

  context 'when receiving valid params' do
    it 'should pass the correct params to the use case' do
      expect_any_instance_of(Hackney::Income::SetTenancyPausedStatus).to receive(:execute).with(
        user_id: paused_parms.fetch(:user_id),
        tenancy_ref: paused_parms.fetch(:tenancy_ref),
        until_date: paused_parms.fetch(:is_paused_until),
        pause_reason: paused_parms.fetch(:pause_reason),
        pause_comment: paused_parms.fetch(:pause_comment),
        action_code: paused_parms.fetch(:action_code)
      ).and_call_original

      patch :update, params: paused_parms

      expect(response.status).to eq(204)
    end

    it 'should return a 200 response' do
      expect_any_instance_of(Hackney::Income::SetTenancyPausedStatus).to receive(:execute).with(
        user_id: params2.fetch(:user_id),
        tenancy_ref: params2.fetch(:tenancy_ref),
        until_date: params2.fetch(:is_paused_until).to_s,
        pause_reason: params2.fetch(:pause_reason),
        pause_comment: params2.fetch(:pause_comment),
        action_code: params2.fetch(:action_code)
      ).and_call_original

      patch :update, params: params2

      expect(response.status).to eq(204)
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

class StubSqlPauseTenancyGateway
  def set_paused_until(tenancy_ref:, until_date:, pause_reason:, pause_comment:); end
end
