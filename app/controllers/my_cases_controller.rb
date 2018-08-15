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
    income_use_case_factory.view_my_cases
  end

  def sync_cases_use_case
    income_use_case_factory.sync_cases
  end

  def random_tenancy_refs
    Hackney::Income::Models::Tenancy.first(100).map { |t| t.tenancy_ref }
  end
end
