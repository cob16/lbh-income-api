require "#{Rails.root}/lib/hackney/service_charge/exceptions/service_charge_exception"
require 'hackney/income/universal_housing_leasehold_gateway.rb'

class LettersController < ApplicationController
  def get_templates
    render json: pdf_use_case_factory.get_templates.execute(
      user: user
    )
  end

  def create
    json = generate_and_store_use_case.execute(
      payment_ref: params_for_generate_and_store[:payment_ref],
      template_id: params_for_generate_and_store[:template_id],
      user: user
    )
    render json: json
  rescue Hackney::Income::TenancyNotFoundError
    head(404)
  end

  def send_letter
    document_model = Hackney::Cloud::Document.find_by!(uuid: params[:uuid])
    Hackney::Income::Jobs::SendLetterToGovNotifyJob.perform_later(document_id: document_model.id)
  end

  private

  def params_for_generate_and_store
    params.permit(
      :payment_ref,
      :template_id,
      user: [:id, :name, :email, groups: []]
    )
  end

  def user
    user_params = params.require(:user).permit(:id, :name, :email, groups: [])

    Hackney::Domain::User.new.tap do |u|
      u.id = user_params['id']
      u.name = user_params['name']
      u.email = user_params['email']
      u.groups = user_params['groups']
    end
  end

  def generate_and_store_use_case
    UseCases::GenerateAndStoreLetter.new
  end
end
