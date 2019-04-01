require 'sidekiq-scheduler'

class GreenInArrearsMessages
  include Sidekiq::Worker

  def perform
    puts '* Scheduling GreenInArrearsMessages *'

    use_case_factory = Hackney::Income::UseCaseFactory.new
    use_case_factory.schedule_green_in_arrears_message.execute
  end
end
