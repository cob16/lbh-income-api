class ApplicationController < ActionController::API
  before_action :set_raven_context, if: :sentry_configured?

  def income_use_case_factory
    @income_use_case_factory ||= Hackney::Income::UseCaseFactory.new
  end

  def set_raven_context
    Raven.extra_context(params: params.to_unsafe_h, url: request.url)
  end

  def sentry_configured?
    ENV.key?('SENTRY_DSN')
  end
end
