class TenanciesController < ApplicationController
  def update
    income_use_case_factory.set_tenancy_paused_status.execute(
      user_id: params.fetch(:user_id),
      tenancy_ref: params.fetch(:tenancy_ref),
      until_date: params.fetch(:is_paused_until),
      pause_reason: params.fetch(:pause_reason),
      pause_comment: params.fetch(:pause_comment),
      action_code: params.fetch(:action_code)
    )

    head(:no_content)
  end

  def pause
    render json: income_use_case_factory.get_tenancy_pause.execute(
      tenancy_ref: params.fetch(:tenancy_ref)
    )
  end
end
