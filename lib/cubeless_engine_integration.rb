module CubelessEngineIntegration
  # Rewrite for Rails 3
  # # Require pieces of the cubeless engine in order to duck punch them. :)
  # def require_cubeless_engine_file(rails_type, file_name)
  #   require "#{Rails.root}/vendor/plugins/cubeless/app/#{rails_type.to_s.pluralize}/#{file_name.to_s}"
  # end
  
  # Require pieces of the cubeless engine in order to duck punch them. :)
  def require_cubeless_engine_file(rails_type, file_name)
    if rails_type.to_s == "lib" || rails_type.to_s == "vendor/plugins" || rails_type.to_s == "components"
      require "#{CubelessBase::Engine.root}/#{rails_type.to_s}/#{file_name.to_s}"  
    else
      require "#{CubelessBase::Engine.root}/app/#{rails_type.to_s.pluralize}/#{file_name.to_s}"  
    end
  end
  
  # Require pieces of the cubeless engine in order to duck punch them. :)
  def require_de_engine_file(rails_type, file_name)
    if rails_type.to_s == "lib" || rails_type.to_s == "vendor/plugins" || rails_type.to_s == "components"
      require "#{DealsAndExtras::Engine.root}/#{rails_type.to_s}/#{file_name.to_s}"  
    else
      require "#{DealsAndExtras::Engine.root}/app/#{rails_type.to_s.pluralize}/#{file_name.to_s}"  
    end
  end
end

Object.__send__ :include, CubelessEngineIntegration
