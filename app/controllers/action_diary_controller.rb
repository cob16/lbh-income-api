class ActionDiaryController < ApplicationController
  REQUIRED_PARAMS = %i[tenancy_ref action_code comment user_id].freeze

  def create
    begin
      rent_use_case_factory.add_action_diary.execute(
        tenancy_ref: action_diary_params.fetch(:tenancy_ref),
        action_code: action_diary_params.fetch(:action_code),
        comment: action_diary_params.fetch(:comment),
        user_id: action_diary_params.fetch(:user_id)
      )
    rescue ArgumentError => e
      render(json: { status: 'error', code: 422, message: e.message }, status: :unprocessable_entity)
      return
    end
    head(:no_content)
  end

  def action_diary_params
    params.require(REQUIRED_PARAMS)
    allowed_params = params.permit(REQUIRED_PARAMS)

    allowed_params[:user_id] = allowed_params[:user_id].to_i

    allowed_params
  end
end
