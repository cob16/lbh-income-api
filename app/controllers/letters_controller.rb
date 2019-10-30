require "#{Rails.root}/lib/hackney/service_charge/exceptions/service_charge_exception"

class LettersController < ApplicationController
  def get_templates
    render json: pdf_use_case_factory.get_templates.execute
  end

  def create
    # letter_data will be a hash of form { html_content:, payment_ref:, template:}
    letter_data = UseCases::ViewLetter.new.execute
    uuid = UseCases::SaveToCache.new(cache: Rails.cache).execute(data: letter_data)

    # we'll have to include some data from the previous
    # use cases to get this response right
    json = pdf_use_case_factory.get_preview.execute(
      payment_ref: params.fetch(:payment_ref),
      template_id: params.fetch(:template_id)
    )

    render json: json
  rescue Hackney::Income::TenancyNotFoundError
    head(404)
  end

  def send_letter
    pop_letter_from_cache = UseCases::PopLetterFromCache.new(cache: Rails.cache)
    letter = pop_letter_from_cache.execute(uuid: params.fetch(:uuid))
    cloud_location = UseCases::SaveLetterToCloud.new.execute(letter)

    # this calls the ProcessLetter use case, which also sends the letter
    income_use_case_factory.send_letter.execute(
      uuid: params.fetch(:uuid),
      user_id: params.fetch(:user_id),
      payment_ref: letter[:case][:payment_ref],
      template_name: letter[:template],
      letter_content: letter[:preview]
    )
  end
end
