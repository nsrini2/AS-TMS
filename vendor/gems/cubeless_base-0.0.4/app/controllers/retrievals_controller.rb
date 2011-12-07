class RetrievalsController < ApplicationController

  allow_access_for :admin_reset => :user_admin

  skip_before_filter :require_auth
  skip_before_filter :require_terms_acceptance

  def new
    @retrieval = Retrieval.new
  end

  def create
    @retrieval = Retrieval.new(params[:retrieval])
    if @retrieval.valid? and Notifier.deliver_retrieval(@retrieval)
      add_to_notices 'Your information was successfully sent.'
      redirect_to "/account/login"
    else
      add_to_errors @retrieval
      params[:forgot] = @retrieval.item
      render :action => "new" 
    end
  end
  
  @@password_validator = UserPasswordValidator.new
  def password_reset
    @rules = @@password_validator.rules_list
    @user = User.find(params[:id])
    add_to_errors 'Your request to reset your password has expired.' and redirect_to '/account/login' and return if @user.temp_crypted_password_expires_at && @user.temp_crypted_password_expires_at < Time.now

    redirect_to '/account/login' and return unless @user.temp_crypted_password == params[:auth]
    if request.post?
      @user.password = params[:user][:new_password]
      @user.password_confirmation = params[:user][:new_password_confirmation]
      if @user.save
        @user.update_attributes(:temp_crypted_password => nil)
        self.current_user = @user
        audit_event(:password_reset)
        add_to_notices "Your password has been reset."
        redirect_to profile_path(current_profile) and return
      else
        add_to_errors @user
      end
    end
  end

  def admin_reset
    @retrieval = Retrieval.new(:item => "password", :login => params[:login])
    user = User.find_by_login(@retrieval.login)
    if @retrieval.valid? and Notifier.deliver_retrieval(@retrieval)
      if user.update_attribute(:crypted_password, nil)
        add_to_notices("This user's password has been reset")
      else
        add_to_errors(@retrieval)
      end
      redirect_to :back
    else
      add_to_errors(@retrieval)
      redirect_to :back
    end
  end

end