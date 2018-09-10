class MyCasesController < ApplicationController
  def index
    cases = income_use_case_factory.view_my_cases.execute(tenancy_refs)
    render json: cases
  end

  def sync
    income_use_case_factory.sync_cases.execute
    render json: { success: true }
  end

  private

  def tenancy_refs
    params.fetch(:tenancy_refs, [])
  end
end
