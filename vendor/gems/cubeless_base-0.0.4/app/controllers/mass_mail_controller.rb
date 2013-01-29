class MassMailController < ApplicationController
  allow_access_for [:all] => :content_admin
  def show
    @mailer = MassMail.new
    render :layout => 'home_admin_sub_menu'
  end
  
  def create
    @mailer = MassMail.new(params[:mailer])
    if @mailer.valid?
      MassMail.delay.send_community_email(@mailer.subject, @mailer.body, { :test_enabled => params[:test_enabled], :current_profile_email => current_profile.email })
      
      add_to_notices "Emails are being sent to #{params[:test_enabled] ? current_profile.email : 'all community members'}."
      
      unless params[:test_enabled]
        redirect_to(success_mass_mail_path) and return 
      end
    else
      add_to_errors @mailer
    end
    render :action => 'show', :layout => 'home_admin_sub_menu'
  end
  
  def success
    render :layout => 'home_admin_sub_menu'
  end

end