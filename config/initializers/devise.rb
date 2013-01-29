# Hack on the Devise Internals to skip our require auth if they skip auth
module Devise
  module Controllers
    module InternalHelpers  
      protected
      alias require_no_authentication_without_hack require_no_authentication
      def require_no_authentication
        self.instance_eval do
          def require_auth
            return true
          end
        end
        require_no_authentication_without_hack
      end
    end
  end
end

# Apparently protected methods are harder to mess with
# Devise::Controllers::InternalHelpers.__send__ :include, InternalHelpersExtension