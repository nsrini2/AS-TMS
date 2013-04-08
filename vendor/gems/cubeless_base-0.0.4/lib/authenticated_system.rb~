module AuthenticatedSystem

  @@current_user = nil

  protected
    # Returns true or false if the user is logged in.
    # Preloads @current_user with the user model if they're logged in.
    def logged_in?
      current_user != :false
    end

    # Accesses the current user from the session.
    def current_user
      first_visit = @current_user.nil? || @current_user==:false
      @@current_user = @current_user ||= (login_from_session || :false)
      # @current_user.profile.update_last_accessed! if first_visit && @current_user && @current_user!=:false && params[:action]!="external" && params[:action]!="external_widget" #!H external
      if first_visit && @current_user && @current_user!=:false && params[:action]!="external" && params[:action]!="external_widget" #!H external
        profile = @current_user.profile 
        profile = [profile].flatten.first unless profile.is_a?(Profile)
        profile.update_last_accessed! if profile.is_a?(Profile)
      end
      @current_user
    end

    def self.current_user
      @@current_user != :false and @@current_user
    end

    def self.current_profile
      self.current_user and Profile.find_by_user_id(current_user.id) #[self.current_user.profile].flatten.compact.last
    end

    # Store the given user in the session.
    def current_user=(new_user)
      session[:user] = (new_user.nil? || new_user.is_a?(Symbol)) ? nil : new_user.id      
      @@current_user = @current_user = nil
      if logged_in?
        cp = self.current_profile
        if cp.status < 1
          self.current_user=nil
        else
          if cp.status==2 || cp.status==3 # enable on login
            cp.status=1 # enabled
            cp.visible=true
            cp.save!
            current_user.temp_user_migration
          end
          #!H exclude external requests coming from Source/FindIt
          if params[:action]!="external" || params[:action]!="external_widget"
            #disabled ActivityStreamEvent.add('Login',nil,nil,:profile_id => current_profile.id)

            p = current_profile
            #!H addint this audit even in tmp, brandon about to refactor add_karma and update of last_login_date
            audit_event(:login) unless p.last_login_date==Date.today
            p.add_karma_for_login!
          end
        end
      end
    end

    # Check if the user is authorized.
    #
    # Override this method in your controllers if you want to restrict access
    # to only a few actions or if you want to check if the user
    # has the correct rights.
    #
    # Example:
    #
    #  # only allow nonbobs
    #  def authorize?
    #    current_user.login != "bob"
    #  end
    def authorized?
      true
    end

    # Filter method to enforce a login requirement.
    #
    # To require logins for all actions, use this in your controllers:
    #
    #   before_filter :login_required
    #
    # To require logins for specific actions, use this in your controllers:
    #
    #   before_filter :login_required, :only => [ :edit, :update ]
    #
    # To skip this in a subclassed controller:
    #
    #   skip_before_filter :login_required
    #
#    def login_required
#      username, passwd = get_auth_data
#      self.current_user ||= User.authenticate(username, passwd) || :false if username && passwd
#      logged_in? && authorized? ? true : access_denied
#    end

    # Redirect as appropriate when an access request fails.
    #
    # The default action is to redirect to the login screen.
    #
    # Override this method in your controllers if you want to have special
    # behavior in case the user is not authorized
    # to access the requested action.  For example, a popup window might
    # simply close itself.
    def access_denied
      respond_to do |accepts|
        accepts.html do
          store_location
          redirect_to :controller => '/account', :action => 'login'
        end
        accepts.xml do
          headers["Status"]           = "Unauthorized"
          headers["WWW-Authenticate"] = %(Basic realm="Web Password")
          render :text => "Could't authenticate you", :status => '401 Unauthorized'
        end
      end
      false
    end

    # Store the URI of the current request in the session.
    #
    # We can return to this location by calling #redirect_back_or_default.
    def store_location
      session[:return_to] = request.url
    end

    # Redirect to the URI stored by the most recent store_location call or
    # to the passed default.
    def redirect_back_or_default(default)
      session[:return_to] ? redirect_to(session[:return_to]) : redirect_to(default)
      session[:return_to] = nil
    end

    # Inclusion hook to make #current_user and #logged_in?
    # available as ActionView helper methods.
    def self.included(base)
      base.send :helper_method, :current_user, :logged_in?
    end

    # When called with before_filter :login_from_cookie will check for an :auth_token
    # cookie and log the user back in if apropriate
    def login_from_cookie
      return unless cookies[:auth_token] && !logged_in?
      user = User.find_by_remember_token(cookies[:auth_token])
      if user && user.remember_token?
        self.current_user = user
        cookies[:auth_token] = { :value => self.current_user.remember_token , :expires => self.current_user.remember_token_expires_at }
        add_to_notices "Logged in successfully"
      end
    end

    def login_from_session
      session[:user] && User.find_by_id(session[:user])
    end

    def login_from_api_key
      @@current_user = @current_user = params[:api_key] && Profile.find_by_api_key(params[:api_key]) && Profile.find_by_api_key(params[:api_key]).user
    end

  private
    @@http_auth_headers = %w(X-HTTP_AUTHORIZATION HTTP_AUTHORIZATION Authorization)
    # gets BASIC auth info
    def get_auth_data
      auth_key  = @@http_auth_headers.detect { |h| request.env.has_key?(h) }
      auth_data = request.env[auth_key].to_s.split unless auth_key.blank?
      return auth_data && auth_data[0] == 'Basic' ? Base64.decode64(auth_data[1]).split(':')[0..1] : [nil, nil]
    end
end
