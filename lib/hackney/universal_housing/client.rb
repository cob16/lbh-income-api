module Hackney
  module UniversalHousing
    class Client
      class << self
        def connection
          TinyTds::Client.new(
            username: configuration.fetch(:username),
            password: configuration.fetch(:password),
            host: configuration.fetch(:host),
            port: configuration.fetch(:port),
            database: configuration.fetch(:database),
            timeout: configuration.fetch(:timeout)
          )
        end

        private

        def configuration
          @configuration ||= begin
            config_file = File.read(Rails.root.join('config', 'database_universal_housing.yml'))
            env_config = YAML.load(ERB.new(config_file).result)[Rails.env.to_s]
            env_config.symbolize_keys
          end
        end
      end
    end
  end
end
