module CubelessStub
  module Models
    
    class Profile < ActiveRecord::Base
      extend ClassMethods
      acts_as_tableless

      column :user_id, :integer
      column :first_name, :string
      column :last_name, :string
      
      belongs_to :user
      
      def screen_name
        [first_name, last_name].compact.join(" ")
      end
      def is_sponsored?
        false
      end
      def visible?
        true
      end
      def online_now?
        true
      end
      def primary_photo_path(*)
        "/"
      end 
      
      
      def self.find(*)
        if id == 1
          self.current
        else
          # MM2: For some reason, this initialization isn't working correctly
          # Profile.new(:id => id, :user_id => 12, :first_name => "Fly", :last_name => "Profile")
          p = Profile.new
          p[:id] = 2
          p[:user_id] = 12
          p[:first_name] = "Fly"
          p[:last_name] = "Profile"
          p
        end
      end
      
      def self.current
        profile = Profile.new
        profile.id = 1
        profile.user_id = 1
        profile.first_name = "T."
        profile.last_name = "Itchy"
        return profile
        # fail profile.inspect
      end

    end

  end
end  