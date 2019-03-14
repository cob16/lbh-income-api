class UsersController < ApplicationController
  def create
    render json: rent_use_case_factory.find_or_create_user.execute(
      provider_uid: params.fetch(:provider_uid),
      provider: params.fetch(:provider),
      name: params.fetch(:name),
      email: params.fetch(:email),
      first_name: params.fetch(:first_name),
      last_name: params.fetch(:last_name),
      provider_permissions: params.fetch(:provider_permissions)
    )
  end
end
