class CasesController < ApplicationController
  REQUIRED_INDEX_PARAMS = %i[page_number number_per_page].freeze

  def index
    response = income_use_case_factory.view_cases.execute(
      page_number: cases_params[:page_number],
      number_per_page: cases_params[:number_per_page],
      filters: {
        is_paused: cases_params[:is_paused],
        classification: cases_params[:recommended_actions],
        patch: cases_params[:patch],
        full_patch: cases_params[:full_patch],
        upcoming_evictions: cases_params[:upcoming_evictions],
        upcoming_court_dates: cases_params[:upcoming_court_dates]
      }
    )

    render json: response
  end

  def cases_params
    params.require(REQUIRED_INDEX_PARAMS)
    allowed_params = params.permit(REQUIRED_INDEX_PARAMS + %i[is_paused patch recommended_actions full_patch upcoming_evictions upcoming_court_dates])

    allowed_params[:is_paused] = ActiveModel::Type::Boolean.new.cast(allowed_params[:is_paused])
    allowed_params[:full_patch] = ActiveModel::Type::Boolean.new.cast(allowed_params[:full_patch])
    allowed_params[:upcoming_court_dates] = ActiveModel::Type::Boolean.new.cast(allowed_params[:upcoming_court_dates])
    allowed_params[:upcoming_evictions] = ActiveModel::Type::Boolean.new.cast(allowed_params[:upcoming_evictions])

    allowed_params[:page_number] = min_1(allowed_params[:page_number].to_i)
    allowed_params[:number_per_page] = min_1(allowed_params[:number_per_page].to_i)

    allowed_params
  end

  def min_1(number)
    [1, number].max
  end

  def sync
    income_use_case_factory.schedule_sync_cases.execute
    render json: { success: true }
  end
end
