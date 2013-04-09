require File.expand_path('../boot', __FILE__)

require 'rails/all'

# If you have a Gemfile, require the gems listed there, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(:default, Rails.env) if defined?(Bundler)

module IterEngineRails3
  class Application < Rails::Application

    # Cubeless specific pre-boot
    require 'crypty'
    CfgCrypt = Crypty.new

    require 'cubeless_config'

    Config.load_config
    CfgCrypt.key = Config['cfg_secret'] || Config['session_secret']
    Config.load_config

    Config.require(:smtp_settings)
    Config.require(:site_base_url)
    
    
    # Load our custom patches for rails/etc
    # config.load_paths += %W( #{RAILS_ROOT}/vendor/patches/lib )
    config.autoload_paths += %W(#{Rails.root}/lib)
  
    # ensure :acts_as_auditable loads before :xss_terminate (no filtering)
    config.plugins = [ :acts_as_auditable, :all ]
  
    # Settings in config/environments/* take precedence over those specified here
    config.action_controller.session = { :session_key => Config.require(:session_key), :secret => Config.require(:session_secret) }
    
    # Skip frameworks you're not going to use (only works if using vendor/rails)
    # config.frameworks -= [ :action_web_service, :action_mailer ]
  
    # Only load the plugins named here, by default all plugins in vendor/plugins are loaded
    # config.plugins = %W( exception_notification ssl_requirement )
  
    config.action_controller.page_cache_directory = Rails.root + "/public/cache/"
    config.action_controller.cache_store = :file_store, Rails.root + "/tmp/cache/"
  
    # Add additional load paths for your own custom dirs
    config.autoload_paths << "#{Rails.root}/components"
    config.autoload_paths << "#{Rails.root}/lib/assist/profile"
    config.autoload_paths << "#{Rails.root}/lib/assist/video"
    config.autoload_paths << "#{Rails.root}/app/observers"
    config.autoload_paths << "#{Rails.root}/app/sweepers"
  
    # Force all environments to use the same logger level
    # (by default production uses :info, the others :debug)
    # config.log_level = :debug
  
    # Use the database for sessions instead of the file system
    # (create the session table with 'rake db:sessions:create')
    # config.action_controller.session_store = :active_record_store
  
    # Use SQL instead of Active Record's schema dumper when creating the test database.
    # This is necessary if your schema can't be completely dumped by the schema dumper,
    # like if you have constraints or database-specific column types
     config.active_record.schema_format = :sql
  
    # Activate observers that should always be running
    # config.active_record.observers = :cacher, :garbage_collector
  
    # Make Active Record use UTC-base instead of local time
    # config.active_record.default_timezone = :utc
  
    # See Rails::Configuration for more options
    #
    config.active_record.observers = :activity_stream_observer, :karma_observer, :watch_observer, :watch_event_observer
  
    config.action_view.sanitized_allowed_attributes = 'style'
    config.after_initialize do
      ActionView::Base.sanitized_allowed_tags << 'u'
    end
    
    config.logger = Logger.new(File.dirname(__FILE__) + "/../log/#{Rails.env}.log") 
    config.logger.formatter = Logger::Formatter.new
  end
end


####

# Documentation

# module IterEngineRails3
#   class Application < Rails::Application
#     # Settings in config/environments/* take precedence over those specified here.
#     # Application configuration should go into files in config/initializers
#     # -- all .rb files in that directory are automatically loaded.
# 
#     # Custom directories with classes and modules you want to be autoloadable.
#     # config.autoload_paths += %W(#{config.root}/extras)
# 
#     # Only load the plugins named here, in the order given (default is alphabetical).
#     # :all can be used as a placeholder for all plugins not explicitly named.
#     # config.plugins = [ :exception_notification, :ssl_requirement, :all ]
# 
#     # Activate observers that should always be running.
#     # config.active_record.observers = :cacher, :garbage_collector, :forum_observer
# 
#     # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
#     # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
#     # config.time_zone = 'Central Time (US & Canada)'
# 
#     # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
#     # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
#     # config.i18n.default_locale = :de
# 
#     # JavaScript files you want as :defaults (application.js is always included).
#     # config.action_view.javascript_expansions[:defaults] = %w(jquery rails)
# 
#     # Configure the default encoding used in templates for Ruby 1.9.
#     config.encoding = "utf-8"
# 
#     # Configure sensitive parameters which will be filtered from the log file.
#     config.filter_parameters += [:password]
#   end
# end


### OLD ONE

# 
# require File.expand_path('../boot', __FILE__)
# 
# module Iter-engine-rails-3
#   class Application < Rails::Application
#     #Require RedCloth  
#     config.gem "RedCloth"
#     require 'RedCloth'
#     
#     config.gem "json", :version => '1.2.4'
#     
#     # require native mysql driver, not the ruby version
#     config.gem 'fastercsv' # admin user import/export
#     config.gem 'mysql'
#   
#     config.gem 'rest-client', :lib => 'rest_client', :version => '1.5.0'
#     
#     config.gem 's3'
#     config.gem 'right_aws'
#   
#     config.gem 'panda', :version => '0.2.1'
#     
#     # Load our custom patches for rails/etc
#     # config.load_paths += %W( #{RAILS_ROOT}/vendor/patches/lib )
#   
#     # ensure :acts_as_auditable loads before :xss_terminate (no filtering)
#     config.plugins = [ :acts_as_auditable, :all ]
#   
#     # Settings in config/environments/* take precedence over those specified here
#     config.action_controller.session = { :session_key => Config.require(:session_key), :secret => Config.require(:session_secret) }
#     
#     # Skip frameworks you're not going to use (only works if using vendor/rails)
#     # config.frameworks -= [ :action_web_service, :action_mailer ]
#   
#     # Only load the plugins named here, by default all plugins in vendor/plugins are loaded
#     # config.plugins = %W( exception_notification ssl_requirement )
#   
#     config.action_controller.page_cache_directory = RAILS_ROOT + "/public/cache/"
#     config.action_controller.cache_store = :file_store, RAILS_ROOT + "/tmp/cache/"
#   
#     # Add additional load paths for your own custom dirs
#     config.autoload_paths << "#{RAILS_ROOT}/components"
#     config.autoload_paths << "#{Rails.root}/lib/assist/profile"
#     config.autoload_paths << "#{Rails.root}/lib/assist/video"
#     config.autoload_paths << "#{RAILS_ROOT}/app/observers"
#     config.autoload_paths << "#{RAILS_ROOT}/app/sweepers"
#   
#     # Force all environments to use the same logger level
#     # (by default production uses :info, the others :debug)
#     # config.log_level = :debug
#   
#     # Use the database for sessions instead of the file system
#     # (create the session table with 'rake db:sessions:create')
#     # config.action_controller.session_store = :active_record_store
#   
#     # Use SQL instead of Active Record's schema dumper when creating the test database.
#     # This is necessary if your schema can't be completely dumped by the schema dumper,
#     # like if you have constraints or database-specific column types
#      config.active_record.schema_format = :sql
#   
#     # Activate observers that should always be running
#     # config.active_record.observers = :cacher, :garbage_collector
#   
#     # Make Active Record use UTC-base instead of local time
#     # config.active_record.default_timezone = :utc
#   
#     # See Rails::Configuration for more options
#     #
#     config.active_record.observers = :activity_stream_observer, :karma_observer, :general_observer, :watch_observer, :watch_event_observer
#   
#     config.action_view.sanitized_allowed_attributes = 'style'
#     config.after_initialize do
#       ActionView::Base.sanitized_allowed_tags << 'u'
#     end
#     
#     config.logger = Logger.new(File.dirname(__FILE__) + "/../log/#{RAILS_ENV}.log") 
#     config.logger.formatter = Logger::Formatter.new
#   
#   end
#   
#   require 'cubeless'
#   
#   # Load config from db
#   begin
#     Config.load_config_from_db
#   rescue
#     Rails.logger.warn "Could not load config from DB: #{$!}"
#   end
#   
#   #Override field error format to include image
#   ActionView::Base.field_error_proc = Proc.new do |html_tag, instance|
#     error_class = "fieldWithErrors"
#     if html_tag =~ /<(input|textarea|select|label)[^>]+class=/
#       class_attribute = html_tag =~ /class=['"]/
#       html_tag.insert(class_attribute + 7, "#{error_class} ")
#     elsif html_tag =~ /<(input|textarea|select|label)/
#       first_whitespace = html_tag =~ /\s/
#       html_tag[first_whitespace] = " class='#{error_class}' "
#     end
#     unless html_tag =~ /<input[^>]+type=\"hidden\"|<label/
#       html_tag = "<div class=\"fieldWithErrors\"><img src=\"/images/errorFieldIconBG.png\" width=\"25\" height=\"25\" alt=\"#{[instance.error_message].flatten.first}\">#{html_tag}</div>"
#     end
#     html_tag
#   end
#   
#   # Add new inflection rules using the following format
#   # (all these examples are active by default):
#   # Inflector.inflections do |inflect|
#   #   inflect.plural /^(ox)$/i, '\1en'
#   #   inflect.singular /^(ox)en/i, '\1'
#   #   inflect.irregular 'person', 'people'
#   #   inflect.uncountable %w( fish sheep )
#   # end
#   
#   # Add new mime types for use in respond_to blocks:
#   # Mime::Type.register "text/richtext", :rtf
#   # Mime::Type.register "application/x-mobile", :mobile
#   Mime::Type.register "application/pdf", :pdf
#   
#   # Support for cloning the activerecord connection
#   module ActiveRecord
#     def Base.clone_connection
#       # capture the current default connection
#       conn = ActiveRecord::Base.connection
#       # make AR create a new base connection
#       ActiveRecord::Base.establish_connection
#       # reconnect our old connection handle!
#       conn.reconnect!
#       conn
#     end
#   end
#   
#   module ActiveRecord::Validations
#     def first_error
#       @errors.full_messages[0]
#     end
#   end
#   
#   # for dev testing only
#   module ActionView::Helpers::AssetTagHelper
#     alias_method :image_tag_pre_dimwarn, :image_tag
#     def image_tag(source, options={})
#       puts "WARNING: image width,height not specified (#{source})" unless options.member?(:size) or options.member?(:width) or options.member?(:height)
#       options[:alt] ||= ''
#       return image_tag_pre_dimwarn(source,options)
#     end
#   end
#   
#   # validate_on_destroy hack
#   class ActiveRecord::Base
#     class ObjectNotDestroyable < ActiveRecord::ActiveRecordError
#     end
#     def destroy_with_validation
#       validate_on_destroy if self.respond_to? :validate_on_destroy
#       if errors.empty?
#         destroy_without_validation
#       end
#     end
#     alias_method_chain :destroy, :validation
#   end
#   
#   # apache 2.0 ProxyPass from http->https does not convert return urls back to http
#   # rails support for the X-Forwarded-Proto header only checks for the 'https' value, not 'http',
#   # which is used in this odd case...
#   # this patch enables http->https->rails proxying (we use this for secure tunnelling from an external network)
#   # rails "normally" supports https->http->rails (where https is normally a load balancer that offloads https processing)
#   class ActionController::AbstractRequest
#     def ssl?
#       xproto = @env['HTTP_X_FORWARDED_PROTO']
#       return xproto=='https' if xproto
#       return @env['HTTPS']=='on'
#     end    
#   end
#   
#   class ActiveRecord::Base
#     class << self
#   
#       # keep reference to untouched find method (since we monkey with the defaults)
#       alias_method :base_find, :find
#   
#       # patch to add :having functionality
#       protected
#       VALID_FIND_OPTIONS << :having
#   
#       private
#       alias_method :add_limit_pre_having!, :add_limit!
#       def add_limit!(sql, options, scope = :auto)
#         having = options.delete(:having)
#         sql << " HAVING (#{having})" if having
#         add_limit_pre_having!(sql,options,scope)
#       end
#     end
#   end
# end

