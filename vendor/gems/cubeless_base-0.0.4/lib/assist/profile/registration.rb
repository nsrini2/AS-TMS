module Assist
  module Profile
    module Registration    
      def has_registration_details
        has_many :profile_registration_fields
        has_many :site_registration_fields, :through => :profile_registration_fields
        attr_accessor :registration
  
        before_create :build_registration_fields
  
        include InstanceMethods
      end  

      module InstanceMethods
        def build_registration_fields
          # Add registration details
          if self.registration
            self.registration.fields.each_pair do |id, attrs|
              self.profile_registration_fields << ProfileRegistrationField.new(:value => attrs['value'], :site_registration_field_id => attrs['id'])
          
              # Tie to the profile if necessary
              if attrs['site_profile_field_id'].to_i > 0
                self.__send__("#{attrs['site_profile_field_question']}=", attrs['value'])
              end
            end
          end
        end
      end
    end
  end
end

ActiveRecord::Base.extend Assist::Profile::Registration