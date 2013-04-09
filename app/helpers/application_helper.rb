require_cubeless_engine_file(:helper, :application_helper)
require_de_engine_file(:helper, :application_helper)

module ApplicationHelper
  include TagsHelper
  # MM2: Overwrite the default cubeless engine marketing_image_tag method to change the width and height
  def marketing_image_tag(message)
    link_to_if(message.link_to_url, image_tag( marketing_image_path(message), :alt => '', :width => "394", :height => "150"),message.link_to_url) if message
  end
    
  def global_nav_link(name, path, id="")
    regexes = { :questions => /questions/,
                "q&amp;a".to_sym => /questions/,
                :groups => /groups/,
                :blogs => /blogs/,
                :news => /news/,
                :chat => /chat/,
                :company => /companies/,
                :"my agency" => /companies/,
                :de => /deals_and_extras/,
                :hub => /(questions|groups|blogs|news|chat|companies|showcase)/ }
                    
    regex = regexes[name.downcase.to_sym]    
    css_class = global_nav_link_active?(name, regex) ? "active" : ""
    # SSJ set class to new background images that are 30x30px 
    # if name =~ /chat/i
    #   id = "new_nav" 
    #   name += "&nbsp;" * 3
    # end  
    "<li id=\"#{id}\" class=\"#{css_class}\">#{link_to name, path}</li>"
  end
  
  def global_nav_link_active?(name, regex)
    name = "de" if name[/deals/i]
    
    if request.url[/companies/]
        name.downcase.to_sym == :"my agency"
    elsif request.url[/deals/i]
        name.downcase.to_sym == :de
    else 
      if name.downcase == "hub"
        (regex && !request.url[regex])
      else
        (regex && request.url[regex])
      end
    end  
  end
  
  def show_logout
    current_profile && !sabre_red_workspace_user
  end
  
  def sabre_red_workspace_user
    # user logged in from SRW
    true if session[:srw_user] && session[:srw_user] == true
  end
  
  def de_request
    request.url[/\/deals_and_extras/]
  end
  alias :de_request? :de_request
  
end
