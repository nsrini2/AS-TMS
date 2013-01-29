# There are issuing using this ActiveForm flavor out of the box with Rails 2.2.x

# The original ActiveForm: http://github.com/nesquena/active_form
# Commit: fd33ef09bd7557fd42f01937f504ec25576bcda2

# Inspired by
# http://puretec.wordpress.com/2009/09/09/activerecorderrors-newself-and-undefined-method-self_and_descendants_from_active_record/#comment-17
# http://gist.github.com/191263

module ActiveFormExtensions
  
  module ClassMethods 
    def self_and_descendents_from_active_record
      [self]
    end
    def human_attribute_name(attribute_key_name, options = {})
      defaults = self_and_descendents_from_active_record.map do |klass|
        "#{klass.name.underscore}.#{attribute_key_name}""#{klass.name.underscore}.#{attribute_key_name}"
      end
      defaults << options[:default] if options[:default]
      defaults.flatten!
      defaults << attribute_key_name.humanize
      options[:count] ||= 1
      I18n.translate(defaults.shift, options.merge(:default => defaults, :scope => [:activerecord, :attributes]))
    end
    def human_name(options = {})
      defaults = self_and_descendents_from_active_record.map do |klass|
        "#{klass.name.underscore}""#{klass.name.underscore}"
      end 
      defaults << self.name.humanize
      I18n.translate(defaults.shift, {:scope => [:activerecord, :models], :count => 1, :default => defaults}.merge(options))
    end
  end
end

ActiveForm.__send__ :extend, ActiveFormExtensions::ClassMethods