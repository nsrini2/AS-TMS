# This file is used by Rack-based servers to start the application.

require ::File.expand_path('../config/environment',  __FILE__)

# puts "**************" + Gem.loaded_specs["rack"].version.to_s

run AgentStream::Application