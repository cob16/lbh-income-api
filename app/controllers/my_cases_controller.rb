class MyCasesController < ApplicationController
  def index
    cases = view_my_cases_use_case.execute(random_tenancy_refs)
    render json: cases
  end

  def sync
    sync_cases_use_case.execute
    render json: { success: true }
  end

  private

  def view_my_cases_use_case
    Hackney::Income::DangerousViewMyCases.new(
      tenancy_api_gateway: Hackney::Income::TenancyApiGateway.new(host: ENV['INCOME_COLLECTION_API_HOST'], key: ENV['INCOME_COLLECTION_API_KEY']),
      stored_tenancies_gateway: Hackney::Income::StoredTenanciesGateway.new
    )
  end

  def sync_cases_use_case
    Hackney::Income::DangerousSyncCases.new(
      prioritisation_gateway: Hackney::Income::UniversalHousingPrioritisationGateway.new,
      uh_tenancies_gateway: Hackney::Income::HardcodedTenanciesGateway.new,
      stored_tenancies_gateway: Hackney::Income::StoredTenanciesGateway.new
    )
  end

  def random_tenancy_refs
    Hackney::Income::Models::Tenancy.first(100).map { |t| t.tenancy_ref }
  end
end
