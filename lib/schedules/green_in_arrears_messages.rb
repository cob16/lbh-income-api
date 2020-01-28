require 'sidekiq-scheduler'

class SendSMSMessages
  include Sidekiq::Worker

  def perform
    puts '* Scheduling SendSMSMessages *'

    use_case_factory = Hackney::Income::UseCaseFactory.new
    use_case_factory.schedule_send_sms.execute
  end
end
