class ApplicationController < ActionController::API
  before_action :set_raven_context

  def rent_use_case_factory
    @rent_use_case_factory ||= Hackney::Rent::UseCaseFactory.new
  end

  def pdf_use_case_factory
    @pdf_use_case_factory ||= Hackney::PDF::UseCaseFactory.new
  end

  def service_charge_use_case_factory
    @service_charge_use_case_factory ||= Hackney::ServiceCharge::UseCaseFactory.new
  end

  def set_raven_context
    Raven.extra_context(params: params.to_unsafe_h, url: request.url)
  end
end
