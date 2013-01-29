# here we are disabling the html_safe measures. our code is really non-compliant.
# treat all strings as safe (same as rails2). re-enable h: explicit escaping
class ERB
  module Util
    def html_escape_h(s)
      return s if ActiveSupport::SafeBuffer===s
      s.to_s.gsub(/[&"><]/) { |special| HTML_ESCAPE[special] }
    end
    remove_method(:h)
    alias h html_escape_h
    module_function :h
  end
end

class Object
  def html_safe?
    true
  end
end

module ActionView::Helpers::TagHelper
  private
  def content_tag_string(name, content, options, escape = true)
    tag_options = tag_options(options, escape) if options
    # "<#{name}#{tag_options}>#{escape ? ERB::Util.h(content) : content}</#{name}>".html_safe
    "<#{name}#{tag_options}>#{content}</#{name}>".html_safe
  end
end