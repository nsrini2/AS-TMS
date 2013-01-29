# Load the rails application
require File.expand_path('../application', __FILE__)

# Initialize the rails application
Agentstream::Application.initialize!
ActiveSupport::Dependencies.autoload_paths << "#{RAILS_ROOT}/app/reports"