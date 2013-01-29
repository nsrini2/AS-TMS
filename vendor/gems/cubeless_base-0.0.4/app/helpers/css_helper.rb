module CssHelper
  def clear_after(selector)
    "#{selector}:after { content: '.'; display: block; height: 0; clear: both; visibility: hidden; } #{selector} { zoom: 1; }"
  end

  # border_radius('5px') => all corners = 5px
  # border_radius('5px', '1px') => top corners = 5px, bottom corners = 1px
  # border_radius('5px', '1px', '5px') => top left = 5px, top right = 1px, bottom corners = 5px
  # border_radius('5px', '1px', '5px', '1px') => top left = 5px, top right = 1px, bottom right = 5px, bottom left = 1px
  def border_radius(topleft, topright=nil, bottomright=nil, bottomleft=nil)
    bottomleft ||= bottomright || topright || topleft
    topright = topleft if bottomright.blank? || topright.blank?
    bottomright ||= bottomleft
    "border-top-left-radius: #{topleft}; -moz-border-radius-topleft: #{topleft}; -webkit-border-top-left-radius: #{topleft}; border-top-right-radius: #{topright}; -moz-border-radius-topright: #{topright}; -webkit-border-top-right-radius: #{topright}; border-bottom-left-radius: #{bottomleft}; -moz-border-radius-bottomleft: #{bottomleft}; -webkit-border-bottom-left-radius: #{bottomleft}; border-bottom-right-radius: #{bottomright}; -moz-border-radius-bottomright: #{bottomright}; -webkit-border-bottom-right-radius: #{bottomright};"
  end

  def box_shadow(val)
    "-moz-box-shadow: #{val}; -webkit-box-shadow: #{val}; box-shadow: #{val};"
  end

  def image(src)
    "/themes/" + Config[:theme] + "/images/" + src
  end

  def global_image(src)
    "/images/" + src
  end

  def site_logo
    if Config[:logo_file].to_s.first == "/"
      Config[:logo_file].to_s
    else
      "/images/custom/" + Config[:logo_file]
    end
  end
  
  def favicon
    if Config[:favicon].to_s.first == "/"
      Config[:favicon].to_s
    else
      "/images/custom/" + Config[:favicon]
    end
  end
  
  def render_css(path)
    if css_debug_enabled
      path.gsub!(/.rcss$/, '.css').gsub!(/^css\//, '')
      "@import url('/css/#{path}');"
    else
      render(:file => path)
    end
  end

  def css_debug_enabled
    @@css_debug_enabled ||= Config[:css_debug]
  end
end