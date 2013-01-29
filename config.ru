# This file is used by Rack-based servers to start the application.
# SSJ 2012-08-10 -- Rack is loaded before this file is loaded
# to preload env for Passenger load bundler in config/setup_load_paths
# fail "\n\n******************** RACK VERSION =  #{Gem.loaded_specs["rack"].version.to_s}  ********************\n\n"

require ::File.expand_path('../config/environment',  __FILE__)
run AgentStream::Application