rails_load_path = File.join(File.dirname(__FILE__), '..', 'config', 'environment')
# load only ouside rails app
if File.exists?(rails_load_path)

  require rails_load_path

  require_relative 'schedules/hello_healthcheck.rb'
  require_relative 'schedules/tenancy_sync.rb'

end
