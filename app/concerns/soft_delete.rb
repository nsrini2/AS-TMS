# SSJ 2012-11-09
# This module overrides the default behavior of ActiveRecord's destroy method to 
# set the value of active to 0 in lieu of deleteing it from the database
# destroy! calls the original destroy method
# I opted not to set the default scope because of company

module SoftDelete
  def self.included(base)
    unless (File.basename($0) == "rake" )  || (ARGV.include?("migration") ) #(File.basename($0) == "rake" && ARGV.include?("db:migrate")  ) ||
      raise ArgumentError, "Table '#{base.table_name}' must have an integer column named 'active' to use SoftDelete!" unless base.column_names.include? 'active'
    end
    base.send :alias_method, :destroy!, :destroy
    # this may seems odd, but specifically including the instance methods
    # is necessary to get the original destry method aliased before they are added
    base.send :include, InstanceMethods
    base.extend ClassMethods
  end
  
  module InstanceMethods
    def destroy
      soft_destroy
    end

    def soft_destroy
      self.active = 0
      if self.save
        return true
      else
        self.errors << "Unable to delete #{self.class}!"
        return false 
      end 
    end
  
    def activate
      self.active = 1
      if self.save
        return true
      else
        self.errors << "Unable to activate #{self.class}!"
        return false 
      end
    end
  end
  
  module ClassMethods
    def inactive
      unscoped.where("#{table_name}.active <= 0")
    end

    def active
      where("#{table_name}.active > 0")
    end
  end
  
end
