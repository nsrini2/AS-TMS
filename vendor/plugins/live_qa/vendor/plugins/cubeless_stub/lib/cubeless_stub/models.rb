module CubelessStub
  module Models
    # module InstanceMethods
    #   def new_record?
    #     false
    #   end
    #   def destroyed?
    #     false
    #   end
    # end
    # 
    module ClassMethods
      
      def acts_as_tableless
        class_inheritable_accessor :columns
        self.columns = []

        def self.column(name, sql_type = nil, default = nil, null = true)
          columns << ActiveRecord::ConnectionAdapters::Column.new(name.to_s, default, sql_type.to_s, null)
        end
      end
      
    end

    def self.require_unless_present_in_app(file_name)
      unless File.exist?("#{Rails.root}/app/models/#{file_name}.rb")
        require File.expand_path(File.dirname(__FILE__) + "/models/#{file_name}")
      end
    end

  end


end

CubelessStub::Models.require_unless_present_in_app('profile')
CubelessStub::Models.require_unless_present_in_app('user')