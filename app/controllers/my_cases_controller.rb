class MyCasesController < ApplicationController
  def index
    cases = income_use_case_factory.view_my_cases.execute(
      user_id: params.fetch(:user_id).to_i,
      page_number: params.fetch(:page_number).to_i,
      number_per_page: params.fetch(:number_per_page).to_i
    )

    render json: cases
  end

  def sync
    income_use_case_factory.sync_cases.execute
    render json: { success: true }
  end
end
