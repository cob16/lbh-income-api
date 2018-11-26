class TenanciesController < ApplicationController
  def update
    income_use_case_factory.set_tenancy_paused_status.execute(
      tenancy_ref: params.fetch(:tenancy_ref),
      until_date: params.fetch(:is_paused_until),
      pause_reason: params.fetch(:pause_reason),
      pause_comment: params.fetch(:pause_comment)
    )

    head(:no_content)
  end
end
