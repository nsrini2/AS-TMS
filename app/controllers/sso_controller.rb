require_cubeless_engine_file :controller, :sso_controller

class SsoController
  skip_before_filter :require_terms_acceptance
  
  
  def accept_terms_and_conditions
    user = current_user
    user.terms_accepted = 1
    unless user.save
      flash[:notice] = "An error occured, please try again"
    end  
    redirect_to "/"
  end
  
  def link_account
    # set a default error message
    flash[:notice] = "An error occured linking your AgentStream accountto your Sabre Red Workspace account.  Please try again."
    if params[:login] && params[:password]
      from_user = current_user
      to_user = User.find_by_login(params[:login])
      to_user = to_user && !params[:password].blank? && to_user.correct_password?(params[:password]) ? to_user : nil
      if to_user && from_user
        new_user = SabreRedWorkspaceTicket.link_users(to_user, from_user)
        if new_user
          self.current_user = new_user
          flash[:notice] = "Your AgentStream account is now linked to your Sabre Red Workspace account."
        end  
      end  
    end
    redirect_to "/"  
  end
  
  def srw
    # validate SSO param ?
    ticket_id = params[:ticketNo] || nil
    unless ticket_id
      @content_for_page_title = "An error occured"
      @message="Please close the community tab in Sabre Red Workspace and re-open this link.  "
      @message+="If the problem persists, please notify us #{view_context.link_to('here', '/feedback')}." 
      render :template => '/shared/_notices', :layout => 'public' and return
    end
    # get ticket from SRW Ticket Builder
    ticket = SabreRedWorkspaceTicket.new(ticket_id)
    unless ticket.valid?
      @content_for_page_title = "Invalid Ticket"
      @message = ticket.error
      render :template => '/shared/_notices', :layout => 'public' and return
    end  

    if ticket.find_or_create_agentstream_user
      # link srw user to AS user or create new as user and go to hub
      self.current_user = ticket.find_or_create_agentstream_user
      session[:srw_user] = true
      redirect_to "/?sso=srw"
    else
      Rails.logger.error "An error occurred creating a user from SRW -- user redirected to '/account/welcome' "
      message="We were unable to connect your account to AgentStream. "
      message+="Please verify you Sabre Red Profile has a valid email address and try to connect again. "
      message+="Or you can login in using your AgentStream account. "
      message+="If you continue to have trouble, please notify us #{view_context.link_to('here', '/feedback')}."
      flash[:notice]=message
      redirect_to "/account/welcome"
    end    
  end
  
end  