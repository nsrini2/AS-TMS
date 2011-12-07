require File.expand_path(File.dirname(__FILE__) + "/helpers/paths")

module CubelessStub
  module Helpers
    include Paths
    include Photos
    
    def current_profile
      ApplicationController.new.current_profile
    end
    
    def logged_in?
      ApplicationController.new.logged_in?
    end
    
    def current_user
      ApplicationController.new.current_user
    end
  
    def global_nav_link(name, path, id="")
      regexes = { :questions => /questions/,
                  "q&amp;a".to_sym => /questions/,
                  :groups => /groups/,
                  :blogs => /blogs/,
                  :news => /news/,
                  :hub => /(questions|groups|blogs|news)/ }

      regex = regexes[name.downcase.to_sym]

      css_class = global_nav_link_active?(name, regex) ? "active" : ""

      "<li id=\"#{id}\" class=\"#{css_class}\">#{link_to name, path}</li>"
    end

    def global_nav_link_active?(name, regex)
      if name.downcase == "hub"
        (regex && !request.url[regex])
      else
        (regex && request.url[regex])
      end
    end

    # Setup for central time
    def pretty_datetime(date)
      eastern_date = date - 5.hours 
      eastern_date.strftime("%b %d, %Y at %I:%M %p") + " Eastern"
    end

    def analytics_tracker_code
      false
    end
    
    def hide_for_sponsor
      true
    end
    
  end
  
end
