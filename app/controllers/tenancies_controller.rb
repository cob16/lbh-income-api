class TenanciesController < ApplicationController
  def show
    @tenancy = income_use_case_factory.get_tenancy.execute(
      tenancy_ref: params.fetch(:tenancy_ref)
    )

    render json: @tenancy.as_json(
      methods: :nosp,
      except: %i[
        days_in_arrears number_of_broken_agreements nosp_expiry_date latest_active_agreement_date
        breach_agreement_date expected_balance
      ]
    ), status: @tenancy.nil? ? :not_found : :ok
  end

  def update
    income_use_case_factory.set_tenancy_paused_status.execute(
      username: params.fetch(:username),
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
  rescue Hackney::Income::SqlPauseTenancyGateway::PauseNotFoundError
    head(404)
  end
end
