require 'sidekiq-scheduler'

class HelloHealthcheck
  include Sidekiq::Worker

  def perform
    puts '* Hello Healthcheck *'
  end
end
