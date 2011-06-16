require_cubeless_engine_file(:controller, :account_controller)

class AccountController < ApplicationController
  before_filter :find_facebook_uid, :only => [:login, :register, :signup, :logout]

  skip_before_filter :require_auth, :only => [:welcome, :register, :login, :reset_password, :logout, :signup, :registration_confirmation]
  skip_before_filter :require_terms_acceptance, :only => [:welcome, :register, :login, :logout, :accept_terms_and_conditions, :sign_up, :registration_confirmation]

  layout 'naked'

  def index
    render :action => 'welcome', :layout => 'public'
  end
    
  def welcome
    render :layout => 'public'
  end
  
  def registration_confirmation
    render :layout => 'public'
  end
  
  def register
    # This is where the FB login button directs its response
    if @facebook_uid
      # user approved connection to Facebook
      user = User.find(:first, :conditions => ["facebook_id = #{@facebook_uid}" ])         
      if user.respond_to?(:locked?)
        # this facebook_id is associated to an AgentStream account
        self.current_user = user
        # get and store/update facebook social graph
        graph = facebook_graph
        if graph
          user.facebook_graph = graph.to_json
          user.save
        end  
        if logged_in?
          # this user has access to AS through Facebook connection
          redirect_back_or_default "/"
        else
          # user account has not yet been activated
          redirect_to :action => :registration_confirmation
        end 
      else
        # Default Action -- Assign FB user to AS user 
        render :action => :register
      end
    else
      # Unable to get FB info (user probably canceled)
      redirect_to :action => :login  
    end
  end
  
  def signup
    return redirect_back_or_default('/profile') unless Config[:open_registration]   
         
    @registration_fields = Config['registration_fields']
    @registration = Registration.new

    if request.post?
      @user = User.new
      @profile = Profile.new
      @profile.attributes = params[:profile]
      @profile.status = 1
      @profile.visible = 1
      @profile.add_roles Role::DirectMember
      @profile.screen_name = "#{params[:profile][:first_name]} #{params[:profile][:last_name]}"
        
      @profile.user = @user
      @user.attributes = params[:user]
      @user.login = params[:user][:login]
      @user.password = params[:user][:password]
      @user.password_confirmation = params[:user][:password_confirmation]
  
      # Grab regitrations details to be validated seperately
      # Also associate it with the profile
      @registration = Registration.new(params[:registration])
      @profile.registration = @registration      
  
      if Config[:registration_queue] 
        if put_user_in_queue
          # add_to_notices "Thanks for signing up for #{Config[:site_name]}! As soon as we verify your account, you'll be sent a welcome email!"
          BatchMailer.mail(@user, Profile.include_user_admins.collect{ |admin| admin.email }.uniq)
          return redirect_to(registration_confirmation_account_path)
        else
          add_to_errors [@user, @profile, @registration]        
        end
      elsif (@registration.valid? & @user.valid? & @profile.valid?) && @user.save && @profile.save
        self.current_user = @user
        add_to_notices "Welcome to #{Config[:site_name]}!"
        Notifier.deliver_welcome(@user)
        audit_event(:signup)
        return redirect_back_or_default('/profile')
      else
        add_to_errors [@user, @profile, @registration]
      end 
    end
    
    if @facebook_uid
      # user approved connection to Facebook
      user = User.find(:first, :conditions => ["facebook_id = #{@facebook_uid}" ])
      graph = facebook_graph
      # if unable to access graph provide blank values
      if graph 
        @first_name = graph['first_name']
        @last_name = graph['last_name']
      else   
        @first_name = ""
        @last_name = ""
      end
    end
    
    if user && user.respond_to?(:locked)
    # he have an active user
      self.current_user = user
      if logged_in?
        redirect_to :action => :login
      else
        redirect_to :action => :registration_confirmation
      end 
    else
      render :action => 'signup'
    end  
  end
  
  def login
    @user = User.new
    return unless request.post? # show login.html.erb
    user = User.find_by_login(params[:login])
    add_to_errors "Your account has been locked due to several unsuccessful login attempts. Please reset your password or contact the administrator." and return if user && user.locked?
    self.current_user = user && !params[:password].blank? && user.correct_password?(params[:password]) ? user : nil
    
    if logged_in?
      # assign facebook_uid to user if available and matches cookies 
      # not sure this double check is necessary, but... 
      if params[:user] && params[:user][:facebook_id] && params[:user][:facebook_id] == @facebook_uid
        current_user.facebook_id = @facebook_uid
        if current_user.save
          flash[:notice] = "AgentStream is now connected to your Facebook account!"
        else
          flash[:errors] = current_user.errors
        end
      end    
      audit_event(:login)
      max_login_failures && current_user.update_attribute(:unsuccessful_login_attempts, 0)
      if current_profile.is_sponsored?
        # MM2: Changed to allow sponsors to follow links as well
        # redirect_to profile_path(current_profile)
        redirect_back_or_default profile_path(current_profile)
      else
        # redirect_back_or_default profile_path(current_profile)
        redirect_back_or_default "/"
      end
    else
      if user && max_login_failures
        update_unsuccessful_login_attempts user
        login_attempts_left = max_login_failures - user.unsuccessful_login_attempts
        login_attempts_left_msg = user.unsuccessful_login_attempts > 0 && "You have #{login_attempts_left} login #{login_attempts_left > 1 ? "attempts" : "attempt"} left."
      # elsif @facbook_uid
      #   # someone logged in with Facebook, but can't get to as
      #   add_to_errors "Something going on with facebook errors"
      end
      add_to_errors "Login id and/or password is invalid. #{login_attempts_left_msg || ""}"
      if params[:user] && params[:user][:facebook_id]
        render :action => :register 
      end  
    end
  end
  
  def logout
    expire_session
    current_profile = nil  # this forces layout to use public
    return redirect_to(Config[:tfce_sso_logout_url]) if Config[:tfce_sso_logout_url] 
    # SSJ: this abstraction keeps a returning user from getting loged out of facebook
    # only actions passed to the logout action log a user out of FB 
    # The user is logged out via a JavaScript on the sing_in view - @facebook_logout triggers this js
    if @facebook_uid 
      @facebook_logout = true
    else
      @facebook_logout = false
    end 
    add_to_notices "You have successfully logged out"
    render :layout => 'naked', :action => 'welcome' 
  end

  
end