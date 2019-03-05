require 'sidekiq-scheduler'

class TenancySync
  include Sidekiq::Worker
  def perform
    use_case_factory = Hackney::Income::UseCaseFactory.new
    use_case_factory.schedule_sync_cases.execute
  end
end
