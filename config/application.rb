require_relative 'boot'
require_relative 'feature_toggle'

require 'rails'
# Pick the frameworks you want:
require 'active_model/railtie'
require 'active_job/railtie'
require 'active_record/railtie'
require 'action_controller/railtie'
require 'action_mailer/railtie'
require 'action_view/railtie'
require 'action_cable/engine'
# require "sprockets/railtie"
# require "rails/test_unit/railtie"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module App
  class Application < Rails::Application
    include FeatureToggle

    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 5.1

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Only loads a smaller set of middleware suitable for API only apps.
    # Middleware like session, flash, cookies can be added back manually.
    # Skip views, helpers and assets when generating a new resource.
    config.api_only = true

    config.eager_load_paths << Rails.root.join('lib')

    config.active_job.queue_adapter = :delayed_job

    config.run_tenancy_sync_jobs = feature_toggle('ENABLE_TENANCY_SYNC')

    config.gov_notify_send_live = feature_toggle('SEND_LIVE_COMMUNICATIONS')
    config.gov_notify_test_phone_number = ENV.fetch('TEST_PHONE_NUMBER', '123456789')
    config.gov_notify_sms_sender_id = ENV.fetch('GOV_NOTIFY_SENDER_ID', SecureRandom.uuid)
    config.gov_notify_test_email_address = ENV.fetch('TEST_EMAIL_ADDRESS', 'test@example.com')
  end
end
