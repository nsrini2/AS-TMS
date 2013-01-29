# require 'cubeless' if File.exists?("#{Rails.root}/vendor/plugins/cubeless")
require File.join(File.dirname(__FILE__), '../../components/cubeless')

# Load config from db
begin
  Config.load_config_from_db
rescue
  Rails.logger.warn "Could not load config from DB: #{$!}"
end

#Override field error format to include image
ActionView::Base.field_error_proc = Proc.new do |html_tag, instance|
  error_class = "fieldWithErrors"
  if html_tag =~ /<(input|textarea|select|label)[^>]+class=/
    class_attribute = html_tag =~ /class=['"]/
    html_tag.insert(class_attribute + 7, "#{error_class} ")
  elsif html_tag =~ /<(input|textarea|select|label)/
    first_whitespace = html_tag =~ /\s/
    html_tag[first_whitespace] = " class='#{error_class}' "
  end
  unless html_tag =~ /<input[^>]+type=\"hidden\"|<label/
    html_tag = "<div class=\"fieldWithErrors\"><img src=\"/images/errorFieldIconBG.png\" width=\"25\" height=\"25\" alt=\"#{[instance.error_message].flatten.first}\">#{html_tag}</div>"
  end
  html_tag
end

# Add new inflection rules using the following format
# (all these examples are active by default):
# Inflector.inflections do |inflect|
#   inflect.plural /^(ox)$/i, '\1en'
#   inflect.singular /^(ox)en/i, '\1'
#   inflect.irregular 'person', 'people'
#   inflect.uncountable %w( fish sheep )
# end

# Add new mime types for use in respond_to blocks:
# Mime::Type.register "text/richtext", :rtf
# Mime::Type.register "application/x-mobile", :mobile
# Mime::Type.register "application/pdf", :pdf

# Support for cloning the activerecord connection
module ActiveRecord
  def Base.clone_connection
    # capture the current default connection
    conn = ActiveRecord::Base.connection
    # make AR create a new base connection
    ActiveRecord::Base.establish_connection
    # reconnect our old connection handle!
    conn.reconnect!
    conn
  end
end

module ActiveRecord::Validations
  def first_error
    @errors.full_messages[0]
  end
end

# for dev testing only
module ActionView::Helpers::AssetTagHelper
  alias_method :image_tag_pre_dimwarn, :image_tag
  def image_tag(source, options={})
    puts "WARNING: image width,height not specified (#{source})" unless options.member?(:size) or options.member?(:width) or options.member?(:height)
    options[:alt] ||= ''
    return image_tag_pre_dimwarn(source,options)
  end
end

# validate_on_destroy hack
class ActiveRecord::Base
  class ObjectNotDestroyable < ActiveRecord::ActiveRecordError
  end
  def destroy_with_validation
  alias_method_chain :destroy, :validation

    validate_on_destroy if self.respond_to? :validate_on_destroy
    if errors.empty?
      destroy_without_validation
    end
  end

end

# apache 2.0 ProxyPass from http->https does not convert return urls back to http
# rails support for the X-Forwarded-Proto header only checks for the 'https' value, not 'http',
# which is used in this odd case...
# this patch enables http->https->rails proxying (we use this for secure tunnelling from an external network)
# rails "normally" supports https->http->rails (where https is normally a load balancer that offloads https processing)
class ActionController::AbstractRequest
  def ssl?
    xproto = @env['HTTP_X_FORWARDED_PROTO']
    return xproto=='https' if xproto
    return @env['HTTPS']=='on'
  end    
end

class ActiveRecord::Base
  class << self

    # keep reference to untouched find method (since we monkey with the defaults)
    alias_method :base_find, :find

    # # patch to add :having functionality
    # protected
    # VALID_FIND_OPTIONS << :having
    # 
    # private
    # alias_method :add_limit_pre_having!, :add_limit!
    # def add_limit!(sql, options, scope = :auto)
    #   having = options.delete(:having)
    #   sql << " HAVING (#{having})" if having
    #   add_limit_pre_having!(sql,options,scope)
    # end
  end
end