module CubelessStub
  module Models

    class User < ActiveRecord::Base
      extend ClassMethods
      acts_as_tableless

      column :login, :string
      column :password, :string
      column :email, :string
      
      has_one :profile   
      
      
      def self.find(*)
        if id == 1
          self.current
        else
          # MM2: For some reason, this initialization isn't working correctly
          # Profile.new(:id => id, :user_id => 12, :first_name => "Fly", :last_name => "Profile")
          user = User.new
          user[:id] = 2
          user[:login] = "smokes"
          user[:password] = "holey"
          user[:email] ="email2@sabre.com"
          user
        end
      end     
      
      def self.current
        user = User.new
        user[:id] = 1
        user[:login] = "itchy"
        user[:password] = "abc123"
        user[:email] ="email@sabre.com"
        user
      end

    end
    
  end
end