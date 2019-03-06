require "#{Rails.root}/lib/hackney/service_charge/exceptions/service_charge_exception"

class PdfController < ApplicationController
  def get_templates
    render json: pdf_use_case_factory.get_templates.execute
  end

  def send_letter
    render json: pdf_use_case_factory.get_preview.execute(
      payment_ref: params.fetch(:payment_ref),
      template_id: params.fetch(:template_id)
    )
  rescue Hackney::ServiceCharge::Exceptions::ServiceChargeException
    head(404)
  end
end
