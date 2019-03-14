require 'sidekiq-scheduler'

class TenancySync
  include Sidekiq::Worker
  def perform
    puts '* TenancySync Running *'
    use_case_factory = Hackney::Rent::UseCaseFactory.new
    use_case_factory.schedule_sync_cases.execute
  end
end
