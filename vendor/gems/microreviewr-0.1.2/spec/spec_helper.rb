$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
# require 'microreviewr'
require 'spec'
require 'spec/autorun'

require File.join(File.dirname(__FILE__), '../lib/microreview')

Spec::Runner.configure do |config|
  
end
