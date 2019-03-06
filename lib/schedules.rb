require File.expand_path(File.join(File.dirname(__FILE__), '..', '..', 'config', 'environment'))

require_relative 'schedules/hello_healthcheck.rb'
require_relative 'schedules/tenancy_sync.rb'
