class GroupInvitationsController < ApplicationController
  deny_access_for [:invitation_popup, :create, :destroy, :invitation_request, :auto_complete_for_group_invitation_profile] => :sponsor_member
  
  def new
    respond_to do |format|
      format.js { render(:partial => 'new_popup', :layout => '/layouts/popup', :locals => { :group_id => params[:group_id] }) }
    end
  end

  def create
    invitation = GroupInvitation.new(:group => Group.find_by_id(params[:invitation][:group_id]), :sender => current_profile, :receiver => Profile.find_by_id(params[:invitation][:suggestion_id]))
    respond_to do |format|
      format.json {
        if invitation.save
          render :text => invitation.to_json
        else
          add_to_errors(invitation)
          render :text => { :errors => flash[:errors] }.to_json
          flash[:errors] = nil
        end
      }
    end
  end

  def destroy
    current_profile.received_invitations.find(params[:id]).destroy
    add_to_notices 'Invitation declined'
    redirect_to groups_profile_path(current_profile)
  end

  def invitation_request
    invite_request = GroupInvitationRequest.new(:sender => current_profile, :group => Group.find(params[:id]))
    respond_to do |format|
      format.html {
        if invite_request.save
          add_to_notices 'Request for invitation sent'
        else
          add_to_errors invite_request
        end
        redirect_to request.referer
      }
    end
  end
  
  def resend
     invite_pending = GroupInvitation.find_by_id(params[:id])
     if is_editable?(invite_pending.group)
         invite_pending.created_at = Time.now
         invite_pending.save!(:validate => false )
         redirect_to request.referer
     end
  end

  def rescind
     invite_pending = GroupInvitation.find_by_id(params[:id])
     if is_editable?(invite_pending.group)
         invite_pending.destroy
         redirect_to request.referer
     end
  end

  def accept_invitation_request
    invite_request = GroupInvitationRequest.find_by_id(params[:id])
    if is_editable?(invite_request.group)
      add_to_notices 'Invitation request accepted' if invite_request.accept
      redirect_to members_group_path(invite_request.group)
    end
  end

  def decline_invitation_request
    invite_request = GroupInvitationRequest.find_by_id(params[:id])
    if is_editable?(invite_request.group)
      add_to_notices 'Invitation request declined' if invite_request.destroy
      redirect_to members_group_path(invite_request.group)
    end
  end

  def auto_complete_for_group_invitation_profile
    profiles = Profile.exclude_sponsor_members.active.limit(20).find_by_full_name(params[:q]).sort{ |x,y| x.full_name <=> y.full_name }
    render :partial => 'shared/name_suggestions', :locals => {:suggestions => profiles}
  end

end
