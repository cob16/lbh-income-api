class MyCasesController < ApplicationController
  before_action :sanitize_params

  REQUIRED_INDEX_PARAMS = %i[user_id page_number number_per_page].freeze

  def index
    response = income_use_case_factory.view_my_cases.execute(
      user_id: view_my_cases_params[:user_id].to_i,
      page_number: view_my_cases_params[:page_number].to_i,
      number_per_page: view_my_cases_params[:number_per_page].to_i,
      is_paused: view_my_cases_params[:is_paused]
    )

    render json: response
  end

  def view_my_cases_params
    params.require(REQUIRED_INDEX_PARAMS)
    params.permit(REQUIRED_INDEX_PARAMS + [:is_paused])
  end

  def sanitize_params
    params[:is_paused] = ActiveModel::Type::Boolean.new.cast(params[:is_paused])
  end

  def sync
    income_use_case_factory.sync_cases.execute
    render json: { success: true }
  end
end
