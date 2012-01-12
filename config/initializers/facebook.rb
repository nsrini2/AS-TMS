require 'koala'
require 'yaml'

# module Koala
#   class << self    
#     attr_accessor :proxy
#     attr_accessor :timeout
#     
#     # Overriding self.make_request
#     # this method is added on include of the NetHTTPServices module
#     # because it is loaded on include it is hard to access via the NetHTTPServices module
#     alias :org_make_request :make_request
#     def make_request(path, args, verb, options = {})
#       options[:proxy] ||= Koala.proxy
#       options[:timeout] ||= Koala.timeout      
#       org_make_request(path, args, verb, options = {})
#     end
#   end
# end
# 
# 
# Koala.timeout = 5 # seconds
# if Rails.env.development?
#   Koala.proxy = ENV["http_proxy"]
# end

# if Rails.env.development?
  Koala.http_service.http_options = {
    :proxy => ENV["http_proxy"]
  }
# end  

fb_config = YAML.load(File.read("#{Rails.root}/config/facebook.yml"))

FB_APP_ID = fb_config["fb_app_id"]
FB_APP_SECRET = fb_config["fb_secret"]