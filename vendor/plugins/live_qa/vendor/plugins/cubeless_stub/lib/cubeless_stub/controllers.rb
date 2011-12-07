module CubelessStub
  module Controllers
    
    def current_profile
      Profile.current
    end
    
    # Returns true or false if the user is logged in.
    # Preloads @current_user with the user model if they're logged in.
    def logged_in?
      false
    end
     
    def current_user
      User.current
    end
    
  end
end