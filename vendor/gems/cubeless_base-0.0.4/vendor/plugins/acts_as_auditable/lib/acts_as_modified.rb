require 'active_record'

module ActsAsModified

  module ActsMethods
    def acts_as_modified
      include InstanceMethods
    end
  end

  module InstanceMethods

    def modified?
      !@_modified_attributes.nil?
    end

    def attribute_modified?(attr_name)
      @_modified_attributes and @_modified_attributes.member?(attr_name.to_s)
    end

    def any_attributes_modified?(*attr_names)
      return false if @_modified_attributes.nil? || attr_names.size==0
      attr_names.each { |attr_name| return true if @_modified_attributes.member?(attr_name.to_s) }
      return false
    end

    def modified_attributes_values(result={})
      @_modified_attributes.each_key { |k| result[k] = attributes[k] } if @_modified_attributes
      result
    end

    # returns a map of modified attributes and their original values
    def modified_attributes_loaded_values
      @_modified_attributes || {}
    end

    # returns a map of changed columns, with a 2-element array of the orig/changed values
    def modified_attributes_changes(result={})
      @_modified_attributes.each_pair { |k,v| result[k] = [v,attributes[k]] } if @_modified_attributes
      result
    end

    def modified_attribute_loaded_value(attr_name)
      @_modified_attributes[attr_name.to_s]
    end

    # Overloaded Methods
    def reload(options=nil)
      @_modified_attributes = nil
      super(options)
    end

    protected
    def write_attribute(attr_name, value)
      attr_name = attr_name.to_s
      return super(attr_name,value) if attribute_modified?(attr_name)
      old_value = read_attribute(attr_name)
      super(attr_name,value)
      if old_value!=read_attribute(attr_name)
        @_modified_attributes = {} unless @_modified_attributes
        @_modified_attributes[attr_name] = old_value
      end
    end

  end

  ActiveRecord::Base.extend ActsMethods

end