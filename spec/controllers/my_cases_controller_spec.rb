require 'rails_helper'

describe MyCasesController do
  describe '#index' do
    context 'when retrieving cases' do
      let(:user_id) { Faker::Number.number(2).to_i }
      let(:page_number) { Faker::Number.number(2).to_i }
      let(:number_per_page) { Faker::Number.number(2).to_i }

      it 'should create the view my cases use case' do
        expect(Hackney::Income::DangerousViewMyCases).to receive(:new).with(
          tenancy_api_gateway: instance_of(Hackney::Income::TenancyApiGateway),
          stored_tenancies_gateway: instance_of(Hackney::Income::StoredTenanciesGateway)
        ).and_call_original

        allow_any_instance_of(Hackney::Income::DangerousViewMyCases)
          .to receive(:execute)
          .and_return([])

        get :index, params: { user_id: user_id, page_number: page_number, number_per_page: number_per_page }
      end

      it 'should call the view my cases use case with the given user_id, page_number and number_per_page' do
        expect_any_instance_of(Hackney::Income::DangerousViewMyCases)
          .to receive(:execute)
          .with(user_id: user_id, page_number: page_number, number_per_page: number_per_page)
          .and_return([])

        get :index, params: { user_id: user_id, page_number: page_number, number_per_page: number_per_page }
      end

      it 'should respond with the results of the view my cases use case' do
        expected_result = [{
          Faker::GreekPhilosophers.name => Faker::GreekPhilosophers.quote
        }]

        allow_any_instance_of(Hackney::Income::DangerousViewMyCases)
          .to receive(:execute)
          .and_return(expected_result)

        get :index, params: { user_id: user_id, page_number: page_number, number_per_page: number_per_page }

        expect(response.body).to eq(expected_result.to_json)
      end
    end
  end

  describe '#sync' do
    it 'should create the sync tenancies use case' do
      expect(Hackney::Income::DangerousSyncCases).to receive(:new).with(
        prioritisation_gateway: instance_of(Hackney::Income::UniversalHousingPrioritisationGateway),
        uh_tenancies_gateway: instance_of(Hackney::Income::UniversalHousingTenanciesGateway),
        stored_tenancies_gateway: instance_of(Hackney::Income::StoredTenanciesGateway)
      ).and_call_original

      allow_any_instance_of(Hackney::Income::DangerousSyncCases)
        .to receive(:execute)
        .and_return([])

      get :sync
    end

    it 'should call the sync tenancies use case' do
      expect_any_instance_of(Hackney::Income::DangerousSyncCases)
        .to receive(:execute)
        .and_return([])

      get :sync
    end

    it 'should respond with { success: true }' do
      allow_any_instance_of(Hackney::Income::DangerousSyncCases)
        .to receive(:execute)
        .and_return([])

      get :sync

      expect(response.body).to eq({ success: true }.to_json)
    end
  end
end
