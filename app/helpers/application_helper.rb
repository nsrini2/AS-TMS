# MM2
# I know this is kind of janky, but it will have to do until all of the cubeless engine in namespaced as such
# Without this require, this controller will completely overwrite the cubeless engine. It will NOT extend it.
require "#{Rails.root}/vendor/plugins/cubeless/app/helpers/application_helper"

module ApplicationHelper

  # MM2: Overwrite the default cubeless engine marketing_image_tag method to change the width and height
  def marketing_image_tag(message)
    link_to_if(message.link_to_url, image_tag( marketing_image_path(message), :alt => '', :width => "399", :height => "150"),message.link_to_url) if message
  end
  
  def global_nav_link(name, path)
    regexes = { :questions => /questions/,
                :groups => /groups/,
                :blogs => /blogs/,
                :community => /(questions|groups|blogs)/ }
                
    regex = regexes[name.downcase.to_sym]
    
    css_class = global_nav_link_active?(name, regex) ? "active" : ""
    
    "<li class=\"#{css_class}\">#{link_to name, path}</li>"
  end
  
  def global_nav_link_active?(name, regex)
    if name.downcase == "community"
      (regex && !request.url[regex])
    else
      (regex && request.url[regex])
    end
  end
end