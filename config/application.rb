require File.expand_path('../boot', __FILE__)

require 'rails/all'

# require 'log4r'
# require 'log4r/yamlconfigurator'
# require 'log4r/outputter/datefileoutputter'
# include Log4r

# Hack to look in engines first
# require 'active_support/dependencies'
# module ActiveSupport::Dependencies
#   alias_method :require_or_load_without_multiple, :require_or_load
#   def require_or_load(file_name, const_path = nil)
#     if file_name.starts_with?(Rails.root.to_s + '/app')
#       relative_name = file_name.gsub(Rails.root.to_s, '')
#       #@engine_paths ||= Rails::Application.railties.engines.collect{|engine| engine.config.root.to_s }
#       #EDIT: above line gives deprecation notice in Rails 3 (although it works in Rails 2), causing error in test env.  Change to:
#       @engine_paths ||= AgentstreamDe::Application.railties.engines.collect{|engine| engine.config.root.to_s }
#       @engine_paths.each do |path|
#         engine_file = File.join(path, relative_name)
#         require_or_load_without_multiple(engine_file, const_path) if File.file?(engine_file)
#       end
#     end
#     require_or_load_without_multiple(file_name, const_path)
#   end
# end


# class MemoryProfiler
#   DEFAULTS = {:delay => 10, :string_debug => false}
# 
#   def self.start(opt={})
#     opt = DEFAULTS.dup.merge(opt)
# 
#     Thread.new do
#       prev = Hash.new(0)
#       curr = Hash.new(0)
#       curr_strings = []
#       delta = Hash.new(0)
# 
#       file = File.open('log/memory_profiler.log','w')
# 
#       loop do
#         begin
#           GC.start
#           curr.clear
# 
#           curr_strings = [] if opt[:string_debug]
# 
#           ObjectSpace.each_object do |o|
#             curr[o.class] += 1 #Marshal.dump(o).size rescue 1
#             if opt[:string_debug] and o.class == String
#               curr_strings.push o
#             end
#           end
# 
#           if opt[:string_debug]
#             File.open("log/memory_profiler_strings.log.#{Time.now.to_i}",'w') do |f|
#               curr_strings.sort.each do |s|
#                 f.puts s
#               end
#             end
#             curr_strings.clear
#           end
# 
#           delta.clear
#           (curr.keys + delta.keys).uniq.each do |k,v|
#             delta[k] = curr[k]-prev[k]
#           end
# 
#           file.puts "Top 20"
#           delta.sort_by { |k,v| -v.abs }[0..19].sort_by { |k,v| -v}.each do |k,v|
#             file.printf "%+5d: %s (%d)\n", v, k.name, curr[k] unless v == 0
#           end
#           file.flush
# 
#           delta.clear
#           prev.clear
#           prev.update curr
#           GC.start
#         rescue Exception => err
#           STDERR.puts "** memory_profiler error: #{err}"
#         end
#         sleep opt[:delay]
#       end
#     end
#   end
# end
# 
# MemoryProfiler.start

# If you have a Gemfile, require the gems listed there, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(:default, Rails.env) if defined?(Bundler)

puts "Loading AgentStream ..."

module AgentStream
  class Application < Rails::Application
    require 'cubeless_engine_integration'
    

    # Not ready yet
    # config.middleware.use ExceptionNotifier,
    #   :email_prefix => "[AgentStream] ",
    #   :sender_address => %{"notifier" <notifier@example.com>},
    #   :exception_recipients => %w{mark.mcspadden@sabre.com scott.johnson@sabre.com}
    
    # Load engine plugins as application plugins
    railties.engines.each do |e|
      engine_lib_path = File.expand_path(e.root.to_s + "/lib")
      engine_components_path = File.expand_path(e.root.to_s + "/components")
      engine_plugins_path = File.expand_path(e.root.to_s + "/vendor/plugins")
      puts "Loading engine: " + engine_plugins_path

      config.paths.vendor.plugins.push engine_plugins_path
      
      config.autoload_paths += %W(#{engine_lib_path} #{engine_components_path})
    end
            
    # Cubeless specific pre-boot
    # require "#{Rails.root}/vendor/plugins/cubeless/lib/crypty"
    require 'crypty'
    CfgCrypt = Crypty.new

    # require "#{Rails.root}/vendor/plugins/cubeless/lib/cubeless_config"
    require 'cubeless_config'

    Config.load_config
    CfgCrypt.key = Config['cfg_secret'] || Config['session_secret']
    Config.load_config

    Config.require(:smtp_settings)
    Config.require(:site_base_url)
    
    
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Custom directories with classes and modules you want to be autoloadable.
    # config.autoload_paths += %W(#{config.root}/extras)
    
    config.autoload_paths += %W(#{Rails.root}/app/observers #{Rails.root}/lib) # Shouldn't nested lib files be autoloaded by default?

    # Only load the plugins named here, in the order given (default is alphabetical).
    # :all can be used as a placeholder for all plugins not explicitly named.
    # config.plugins = [ :exception_notification, :ssl_requirement, :all ]
    
    # config.plugin_path += ["#{Rails.root}/vendor/plugins/cubeless/vendor/plugins"]

    # ensure :acts_as_auditable loads before :xss_terminate (no filtering)
    #config.plugins = [ :cubeless, :acts_as_auditable, :all ]
    

    # Activate observers that should always be running.
    # config.active_record.observers = :cacher, :garbage_collector, :forum_observer

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    # config.time_zone = 'Central Time (US & Canada)'
    config.time_zone = 'Central Time (US & Canada)'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de

    # JavaScript files you want as :defaults (application.js is always included).
    # config.action_view.javascript_expansions[:defaults] = %w(jquery rails)

    # Configure the default encoding used in templates for Ruby 1.9.
    config.encoding = "utf-8"

    # Configure sensitive parameters which will be filtered from the log file.
    config.filter_parameters += [:password]
    
    # More cubeless specific stuff
    config.active_record.observers = :activity_stream_observer, :karma_observer #, :general_observer, :watch_observer, :watch_event_observer

    config.action_view.sanitized_allowed_attributes = 'style'
    config.after_initialize do
      ActionView::Base.sanitized_allowed_tags << 'u'
    end
    # DEFAULT LOGGER
    # config.logger = Logger.new(File.dirname(__FILE__) + "/../log/#{Rails.env}.log") 
    # config.logger.formatter = Logger::Formatter.new
    
    # BUFFERED LOGGER
    Rails.logger = ActiveSupport::BufferedLogger.new(File.dirname(__FILE__) + "/../log/#{Rails.env}.log")
    
    # log4r
    # SSF 1-16-2013 for some reason this does not log anything in production unlese started from the console
    # log4r_config= YAML.load_file(File.join(File.dirname(__FILE__),"log4r.yml"))
    # YamlConfigurator.decode_yaml( log4r_config['log4r_config'] )
    # Rails.logger = Log4r::Logger[Rails.env]
  end
end
