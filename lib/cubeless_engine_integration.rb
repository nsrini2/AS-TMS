module CubelessEngineIntegration
  # Require pieces of the cubeless engine in order to duck punch them. :)
  def require_cubeless_engine_file(rails_type, file_name)
    require "#{Rails.root}/vendor/plugins/cubeless/app/#{rails_type.to_s.pluralize}/#{file_name.to_s}"
  end
end

Object.__send__ :include, CubelessEngineIntegration