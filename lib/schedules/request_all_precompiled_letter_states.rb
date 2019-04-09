require 'sidekiq-scheduler'
class RequestAllPrecompiledLetterStates
  include Sidekiq::Worker

  def perform
    puts '* Scheduling RequestAllPrecompiledLetterState *'
    income_use_case_factory.enqueue_request_all_precompiled_letter_states.execute
  end

  private

  def income_use_case_factory
    @income_use_case_factory ||= Hackney::Income::UseCaseFactory.new
  end
end
