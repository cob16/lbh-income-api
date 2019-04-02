require 'sidekiq-scheduler'

class TenancySync
  include Sidekiq::Worker
  def perform
    puts '* TenancySync Running *'
    use_case_factory = Hackney::Income::UseCaseFactory.new

    max_retries = 3
    retry_count = 0
    delay = 1.minute

    begin
      use_case_factory.schedule_sync_cases.execute
    rescue Sequel::DatabaseConnectionError => err
      raise 'All retries are exhausted' if retry_count >= max_retries
      retry_count += 1
      puts "[#{Time.now}] Oh no, we failed on #{err.inspect}."

      pute "Retries left: #{max_retries - retry_count}"
      sleep delay += retry_count
      retry
    end
  end
end
