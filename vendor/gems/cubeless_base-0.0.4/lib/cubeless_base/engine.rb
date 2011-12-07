require 'cubeless_base'
require "rails"

module CubelessBase
  class Engine < Rails::Engine
    puts "CubelessBase Engine"

    # paths.vendor               "vendor", :load_path => true
    # paths.vendor.plugins      "vendor/plugins"

  #   $: << File.expand_path(File.dirname(__FILE__) + "/../../lib/assist/profile")

    paths.lib << "lib/assist/profile"

    engine_name :cubeless_base
    
    initializer :pre_initializers, :before => :load_config_initializers do |app|
      # app.config.paths.vendor.plugins.push File.expand_path(File.dirname(__FILE__) + "/../../vendor/plugins")
      # 
      # puts "^^^^^^^"
      # puts app.railties.all
      # puts "^^^^^^^"
      # puts "ppppppppp"
      # puts app.railties.plugins
      # puts "ppppppppp"
      # 
      # app.railties.instance_variable_set("@plugins", nil)
      # puts "p2222222222pppppppp"
      # app.railties.plugins.each do |p|
      #   puts p
      #   p.initialize
      #   # p.handle_lib_autoload
      #   # p.load_init_rb
      #   # p.sanity_check_railties_collision
      # end
      # puts "p2222222222pppppppp"

      
      app.config.paths.vendor.plugins.each do |path|
        puts path
        10.times{ puts "" }
        puts "---------------------------------------------"
                10.times{ puts "" }
      end
      
      # app.config.paths.vendor.plugins.to_a.sort.each do |plugin|
      #   load(plugin)
      # end
      # 
      # Dir.glob(File.expand_path(File.dirname(__FILE__) + "/../../vendor/plugins/**")).each do |path|
      #   # puts path
      #   # $: << path + "/lib"
      #   # require(path + "/init.rb")
      #   
      #   $:.unshift(path+'/lib')
      #   # puts $:
      #   require(path+'/init.rb')
      # end
    end

    
    # def self.root
    #   File.expand_path(File.dirname(File.dirname(__FILE__)))
    # end

    # def self.models_dir
    #   "#{root}/app/models"
    # end
    # 
    # def self.controllers_dir
    #   "#{root}/app/controllers"
    # end
    
    # HACK FOR LOADING PLUGINS
    # initializer 'my_engine.testing', :before => :set_autoload_paths do |app|
    #   puts "Do stuff"
    # 
    # 
    # 
    # 
    #   app.config.paths.vendor.plugins.push File.expand_path(File.dirname(__FILE__) + "/../../vendor/plugins")
    #   #puts app.config.paths.vendor.plugins.inspect
    #   # app.config.plugins = [ :acts_as_auditable, :all ]
    #   
    #   app.config.paths.vendor.plugins.each do |path|
    #     puts path.inspect
    #     puts "--------"
    #   end
    #   
    # end
    
    # 
    # config.before_initialize do 
    #   puts "Do stuff"
    # 
    #   Rails.application.config.paths.vendor.plugins.push File.expand_path(File.dirname(__FILE__) + "/../../vendor/plugins")
    #   #puts app.config.paths.vendor.plugins.inspect
    #   # app.config.plugins = [ :acts_as_auditable, :all ]
    #   
    #   Rails.application.config.paths.vendor.plugins.each do |path|
    #     puts path.inspect
    #     puts "--------"
    #   end
    #   
    #     puts "$$$"
    #     puts $:
    #     Dir.glob(File.expand_path(File.dirname(__FILE__) + "/../../vendor/plugins/**/init.rb")).each do |path|
    #       puts path
    #       require path
    #     end
    #   
    # #   puts "Do stuff"
    # # 
    # # 
    # # 
    # # 
    # #   Rails.application.config.paths.vendor.plugins += File.expand_path(File.dirname(__FILE__) + "/../../vendor/plugins")
    # #   puts Rails.application.config.paths.vendor.plugins.inspect
    # #   # 
    # #   # puts "$$$"
    # #   # puts File.expand_path(File.dirname(__FILE__) + "/../../vendor/plugins")
    # #   # puts "$$$"
    # #   # Dir.glob(File.expand_path(File.dirname(__FILE__) + "/../../vendor/plugins/**/init.rb")).each do |path|
    # #   #   puts path
    # #   #   require path
    # #   # end
    # end
  end
end