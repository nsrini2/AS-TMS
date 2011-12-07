require 'net/http'
class Net::HTTP

  # Convenience method. Returns a Proxy from a URI object or string. Returns Net::HTTP if nil.
  def self.UriProxy(uri)
    return Net::HTTP unless uri
    uri = URI.parse(uri) if uri.is_a?(String)
    Net::HTTP::Proxy(uri.host,uri.port,uri.user,uri.password)
  end
  
  # Returns a Proxy if env:http_proxy is set, and if host does not match any patterns in env:no_proxy. Returns Net::HTTP otherwise.
  @@env_no_proxy ||= begin
    ['127.0.0.1','localhost'].concat(ENV.fetch('no_proxy','').split(',').collect! { |p|
      next Regexp.new("^#{Regexp.escape(p).sub('\*','.*')}$") if /\*/===p
      # if it's just a 2nd level domain, google.com, consider as a leading wildcard
      next Regexp.new("#{Regexp.escape(p)}$") if p.split('.').size==2
      p
    })
  end
  def self.EnvProxy(host=nil)
    @@env_net ||= UriProxy(ENV['http_proxy'])
    @@env_no_proxy.each { |p| return Net::HTTP if p===host } if host && @@env_net!=Net::HTTP
    @@env_net
  end
  
  class << self
    alias_method :pre_env_proxy_new, :new
    def new(address, port = nil, p_addr = nil, p_port = nil, p_user = nil, p_pass = nil)
      if p_addr.nil? && !proxy_class?
        env_proxy = EnvProxy(URI===address ? address.host : address)
        return env_proxy.new(address,port) if env_proxy.proxy_class?
      end
      result = pre_env_proxy_new(address,port,p_addr,p_port,p_user,p_pass)
      if port==443 || (URI===address && address.scheme=='https')
        result.use_ssl = true
        result.verify_mode = OpenSSL::SSL::VERIFY_NONE
      end
      result.open_timeout = 4
      result
    end
  end
  
end


# Load initializers from plugin
# require "#{Rails.root}/vendor/plugins/cubeless/config/initializers/compass"
# require "#{Rails.root}/vendor/plugins/cubeless/config/initializers/assist"

# require "#{Rails.root}/vendor/plugins/cubeless/config/initializers/delayed_job"
# require "#{Rails.root}/vendor/plugins/cubeless/config/initializers/editable_by"
# require "#{Rails.root}/vendor/plugins/cubeless/config/initializers/geokit"
# require "#{Rails.root}/vendor/plugins/cubeless/config/initializers/new_defaults"
# require "#{Rails.root}/vendor/plugins/cubeless/config/initializers/panda"
# require "#{Rails.root}/vendor/plugins/cubeless/config/initializers/reports"
# require "#{Rails.root}/vendor/plugins/cubeless/config/initializers/xss"
# 
# 
# require "#{Rails.root}/vendor/plugins/cubeless/components/cubeless"

# Load config from db
begin
  Config.load_config_from_db
rescue
  Rails.logger.warn "Could not load config from DB: #{$!}"
end

#Override field error format to include image
ActionView::Base.field_error_proc = Proc.new do |html_tag, instance|
  error_class = "fieldWithErrors"
  if html_tag =~ /<(input|textarea|select|label)[^>]+class=/
    class_attribute = html_tag =~ /class=['"]/
    html_tag.insert(class_attribute + 7, "#{error_class} ")
  elsif html_tag =~ /<(input|textarea|select|label)/
    first_whitespace = html_tag =~ /\s/
    html_tag[first_whitespace] = " class='#{error_class}' "
  end
  unless html_tag =~ /<input[^>]+type=\"hidden\"|<label/
    # html_tag = "<div class=\"fieldWithErrors\"><img src=\"/images/errorFieldIconBG.png\" width=\"25\" height=\"25\" alt=\"#{[instance.error_message].flatten.first}\">#{html_tag}</div>"
    # html_tag = "<div class=\"fieldWithErrors\">#{html_tag}</div>"
  end
  html_tag
end

# Add new inflection rules using the following format
# (all these examples are active by default):
# Inflector.inflections do |inflect|
#   inflect.plural /^(ox)$/i, '\1en'
#   inflect.singular /^(ox)en/i, '\1'
#   inflect.irregular 'person', 'people'
#   inflect.uncountable %w( fish sheep )
# end

# Add new mime types for use in respond_to blocks:
# For now
# ActiveSupport::Deprecation.silenced = true


# Mime::Type.register "text/richtext", :rtf
# Mime::Type.register "application/x-mobile", :mobile
Mime::Type.register "application/pdf", :pdf

# Support for cloning the activerecord connection
module ActiveRecord
  def Base.clone_connection
    # capture the current default connection
    conn = ActiveRecord::Base.connection
    # make AR create a new base connection
    ActiveRecord::Base.establish_connection
    # reconnect our old connection handle!
    conn.reconnect!
    conn
  end
end

module ActiveRecord::Validations
  def first_error
    @errors.full_messages[0]
  end
end

# for dev testing only
# module ActionView::Helpers::AssetTagHelper
#   alias_method :image_tag_pre_dimwarn, :image_tag
#   def image_tag(source, options={})
#     puts "WARNING: image width,height not specified (#{source})" unless options.member?(:size) or options.member?(:width) or options.member?(:height)
#     options[:alt] ||= ''
#     return image_tag_pre_dimwarn(source,options)
#   end
# end

# validate_on_destroy hack
class ActiveRecord::Base
  class ObjectNotDestroyable < ActiveRecord::ActiveRecordError
  end
  def destroy_with_validation
    validate_on_destroy if self.respond_to? :validate_on_destroy
    if errors.empty?
      destroy_without_validation
    end
  end
  alias_method_chain :destroy, :validation
end

# apache 2.0 ProxyPass from http->https does not convert return urls back to http
# rails support for the X-Forwarded-Proto header only checks for the 'https' value, not 'http',
# which is used in this odd case...
# this patch enables http->https->rails proxying (we use this for secure tunnelling from an external network)
# rails "normally" supports https->http->rails (where https is normally a load balancer that offloads https processing)
class ActionController::AbstractRequest
  def ssl?
    xproto = @env['HTTP_X_FORWARDED_PROTO']
    return xproto=='https' if xproto
    return @env['HTTPS']=='on'
  end    
end

# class ActiveRecord::Base
#   class << self
# 
#     # keep reference to untouched find method (since we monkey with the defaults)
#     alias_method :base_find, :find
# 
#     # patch to add :having functionality
#     protected
#     VALID_FIND_OPTIONS << :having
# 
#     private
#     alias_method :add_limit_pre_having!, :add_limit!
#     def add_limit!(sql, options, scope = :auto)
#       having = options.delete(:having)
#       sql << " HAVING (#{having})" if having
#       add_limit_pre_having!(sql,options,scope)
#     end
#   end
# end

ActionMailer::Base.smtp_settings = Config[:smtp_settings]

# Include your application configuration below
require 'table_for'
require 'getthere_integration'

require 'RMagick'  
require 'spawn'