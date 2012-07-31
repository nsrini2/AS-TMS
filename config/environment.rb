# Load the rails application
require File.expand_path('../application', __FILE__)

# Load the correct version of Rack
Config.gem "rack", :version=>'1.2.5'

# Initialize the rails application
AgentStream::Application.initialize!