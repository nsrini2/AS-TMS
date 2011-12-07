# require 'right_aws'
require 'panda'
require 'json'

if RAILS_ENV['development']
  # Setup Proxy
  # RestClient.proxy = "http://proxy.example.com/"
  #
  # Or inherit the proxy from the environment:
  #
  RestClient.proxy = ENV['http_proxy']
end

module Panda
  class << self
    attr_reader :cloud_id, :access_key, :secret_key
  end
end

Panda.connect!(YAML::load_file(File.join(File.dirname(__FILE__),'..', 'panda.yml'))[RAILS_ENV]) if File.exist?(File.join(File.dirname(__FILE__),'..', 'panda.yml'))

# PANDA_URL = "http://upload.cubeless.com"

# PANDA_ENCODING = "Flash video SD"
# VIDEOS_DOMAIN = "s3.amazonaws.com/cubeless_video_test"

# Panda.account_key = "SECRET_KEY_FOR_PANDA_API"
# Panda.api_domain = "ec2-184-73-111-165.compute-1.amazonaws.com"
# Panda.api_port = 80


# The JSON gem introduces an error with ActiveSupport 2.1.1
# This is an attempt to fix it
module CubelessJsonHack
  def to_json(*args)
    h = self.attributes
    
    options = args.first
    if options && options[:methods]
      ms = options[:methods]
      if ms.is_a?(String) || ms.is_a?(Symbol)
        ms = [ms] 
      end
      
      ms.each do |m|
        h.merge!({ m => self.send(m.to_sym) })
      end
    end
    
    { "#{self.class.to_s.underscore}".to_sym => h }.to_json
  end
end
ActiveRecord::Base.send :include, CubelessJsonHack
