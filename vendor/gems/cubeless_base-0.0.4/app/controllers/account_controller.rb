require 'user_password_validator'

class AccountController < ApplicationController

  skip_before_filter :require_auth, :only => [:login, :reset_password, :logout, :signup, :registration_confirmation]
  skip_before_filter :require_terms_acceptance, :only => [:login, :logout, :accept_terms_and_conditions, :sign_up, :registration_confirmation]

  def login
    @user = User.new
    return unless request.post? # show login.html.erb

    user = User.find_by_login(params[:login])
    add_to_errors "Your account has been locked due to several unsuccessful login attempts. Please reset your password or contact the administrator." and return if user && user.locked?
    self.current_user = user && !params[:password].blank? && user.correct_password?(params[:password]) ? user : nil

    if logged_in?
      audit_event(:login)
      max_login_failures && current_user.update_attribute(:unsuccessful_login_attempts, 0)
      if current_profile.is_sponsored?
        # MM2: Changed to allow sponsors to follow links as well
        # redirect_to profile_path(current_profile)
        redirect_back_or_default profile_path(current_profile)
      else
        redirect_back_or_default profile_path(current_profile)
      end
    else
      if user && max_login_failures
        update_unsuccessful_login_attempts user
        login_attempts_left = max_login_failures - user.unsuccessful_login_attempts
        login_attempts_left_msg = user.unsuccessful_login_attempts > 0 && "You have #{login_attempts_left} login #{login_attempts_left > 1 ? "attempts" : "attempt"} left."
      end
      add_to_errors "Login id and/or password is invalid. #{login_attempts_left_msg || ""}"
    end
  end

  def logout
    expire_session
    add_to_notices "You have successfully logged out"
    return redirect_to(Config[:tfce_sso_logout_url]) if Config[:tfce_sso_logout_url]
    redirect_to '/'
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
    
    render :action => 'signup'
  end

  def email_subscriptions
    def self.is_true?(blah)
      blah == true || blah == 1 || blah == "1" ? true : false
    end
    
    def use_global_email_preferences?
      params["commit"] == "Save and Use Global Settings" || params["use_global_email_preferences"] == "true" 
    end
    @profile = current_profile
    action_post do
      if use_global_email_preferences?
        @profile.turn_on_global_group_email_preferences!
        @profile.update_attributes(params[:profile])
      elsif
        @profile.update_attributes(params[:profile])
        @profile.turn_off_global_group_email_preferences!
        @profile.group_memberships.each do |membership|
          prefs = membership.email_preferences
          new_prefs = params[:group_membership][membership.id.to_s]
          prefs.note = self.is_true?(new_prefs["note"])
          prefs.blog_post = self.is_true?(new_prefs["blog_post"])
          prefs.group_talk_post = self.is_true?(new_prefs["group_talk_post"])
          prefs.referred_question = self.is_true?(new_prefs["referred_question"])
          membership.save
        end
      end
      add_to_notices 'Email Subscriptions successfully updated.'
    end
    render :layout => 'settings'
  end

  @@password_validator = UserPasswordValidator.new
  def change_password
    return respond_not_authorized if logged_in? and !current_user.uses_login_pass?
    @user = current_user
    @rules = @@password_validator.rules_list
    action_post do
      @user.current_password = params[:user][:current_password]
      @user.password = params[:user][:password]
      @user.password_confirmation = params[:user][:password_confirmation]
      if @user.save
        audit_event(:password_changed)
        add_to_notices 'Password successfully updated.'
        return redirect_to(email_subscriptions_account_path)
      else
        add_to_errors @user
      end
    end
    render :layout => 'settings'
  end

  def change_email    
    return respond_not_authorized if logged_in? and !current_user.can_change_email?
    return respond_not_authorized if Config['frozen_emails']
    
    @user = current_user
    action_post do
      @user.current_password = params[:user][:current_password]
      audit_event(:email_changed, :old => @user.email, :new => params[:user][:email])
      if @user.update_attributes(params[:user])
        add_to_notices 'Email successfully updated.'
      else
        add_to_errors @user
      end
    end
    render :layout => 'settings'
  end

  def accept_terms_and_conditions
    current_user.toggle!(:terms_accepted)
    add_to_notices 'Thanks for accepting the Terms and Conditions.'
    # send welcome note
    msg = WelcomeNote.get
    cp.notes.create(:sender_id => msg.profile_id, :message => msg.text) if msg.profile && msg.text

    redirect_back_or_default profile_path(current_profile)
  end
  
  def registration_confirmation
    
  end

  protected
  def update_unsuccessful_login_attempts(user)
    return unless max_login_failures
    if user
      user.unsuccessful_login_attempts += 1
      user.save
      if user.unsuccessful_login_attempts >= max_login_failures
        user.locked_until = Config['user.lockout.duration'].from_now
        user.unsuccessful_login_attempts = 0
        user.save!
        add_to_errors "Your account has been locked due to several unsuccessful login attempts. Please reset your password or contact the administrator."
      end
    end
  end
  
  private
  def max_login_failures
    Config['user.lockout.failures']
  end
  
  def put_user_in_queue    
    @profile.status = -3
    @profile.visible = 0
    (@registration.valid? & @user.valid? & @profile.valid?) && @user.save && @profile.save
  end

end
