redis_url = ENV.fetch('REDIS_URL')

Sidekiq.configure_server do |config|
  # config.redis = { url: "redis://redis:6379" }
  config.redis = { url: "redis://#{redis_url}" }
end

Sidekiq.configure_client do |config|
  config.redis = { url: "redis://#{redis_url}" }
end

Sidekiq.default_worker_options = {
  retry: false
}
