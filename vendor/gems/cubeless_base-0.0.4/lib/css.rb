require 'erb'

class CSS
  include CssHelper

  def initialize
    path = File.exists?("#{Rails.root}/app/views/css/screen.rcss") ? "#{Rails.root}/app/views/css/screen.rcss" : "#{CubelessBase::Engine.root.to_s}/app/views/css/screen.rcss"
    @rcss = ERB.new(File.read(path))
    @theme_colors = Config[:themes][Config[:theme]]
  end

  def generate
    File.delete("#{RAILS_ROOT}/public/stylesheets/screen.css") if File.exists?("#{RAILS_ROOT}/public/stylesheets/screen.css")

    File.open("#{RAILS_ROOT}/public/stylesheets/screen.css", "w") do |f|
      f.write( @rcss.result(binding) )
    end
  end

  def render(path)
    path = path[:file] # Fix for Rails 2.3
    path = File.exists?("#{Rails.root}/app/views/#{path}") ? "#{Rails.root}/app/views/#{path}" : "#{CubelessBase::Engine.root.to_s}/app/views/#{path}"
    ERB.new(File.read(path)).result(binding)
  end
end