class SponsorGroupsController < ApplicationController
  layout 'sponsor_accounts_sub_menu'

  allow_access_for :all => :sponsor_admin

  def index
    @sponsor_account = SponsorAccount.find(params[:sponsor_account_id])
    @sponsor_groups=@sponsor_account.groups.paginate(:page => params[:page], :per_page => 5)
  end

  def new
    @sponsor_account = SponsorAccount.find(params[:sponsor_account_id])
    @sponsor_group = Group.new
    @group_types=[["Public",0],["Invitation Only",1],["Private",2]]
  end

  def edit
    @sponsor_account=SponsorAccount.find(params[:sponsor_account_id])
    @sponsor_group=@sponsor_account.groups.find(params[:id])
    @group_types=[["Public",0],["Invitation Only",1],["Private",2]]
  end


  def update
    @sponsor_account = SponsorAccount.find(params[:sponsor_account_id])
    @sponsor_group=@sponsor_account.groups.find(params[:id])
    @group_types=[["Public",0],["Invitation Only",1],["Private",2]]
    @sponsor_group.update_attributes(params[:sponsor_group])
    if @sponsor_group.save
        flash[:notice] = "Booth #{@sponsor_group.name} was updated!"
        redirect_to sponsor_account_sponsor_groups_path(@sponsor_account)
    else
         flash[:errors] = @sponsor_group.errors
         render :action => "edit"
    end
  end


  def create
    @group_types=[["Public",0],["Invitation Only",1],["Private",2]]
    @sponsor_account = SponsorAccount.find(params[:sponsor_account_id])
    @sponsor_group = Group.create(params[:sponsor_group].merge!({ :sponsor_account_id => @sponsor_account.id, 
                                                                  :owner => @sponsor_account.sponsors.find(params[:sponsor_group][:owner_id])}))
    if @sponsor_group.save
      add_to_notices "#{@sponsor_group.name.titleize} has been saved"
      redirect_to sponsor_account_sponsor_groups_path(@sponsor_account)
    else
      flash[:errors] = @sponsor_group.errors
      render :action => "new"
    end
  end
  

  def delete
    @sponsor_account = SponsorAccount.find( params[:sponsor_account_id] )
    @sponsor_group = @sponsor_account.groups.find(params[:id])
  end
  

  def destroy
    @sponsor_account = SponsorAccount.find(params[:sponsor_account_id])
    @sponsor_group = @sponsor_account.groups.find(params[:id])
    if params[:commit] == 'Yes'
      name = @sponsor_group.name
      @sponsor_group.destroy
      add_to_notices "#{name} Sponsored Group was deleted"
    end
    redirect_to sponsor_accounts_path
  end
  
  def add_sponsor
    begin
      @sponsor_account = SponsorAccount.find(params[:sponsor_account_id])
      @sponsor_group = @sponsor_account.groups.find(params[:id])
      @sponsor = @sponsor_account.sponsors.find(params[:profile][:id])
      
      # MM2: Ok. Here's the deal. 
      # If a group is NOT public, then under most circumstances a member is required to have an invite to join the group.
      # This is enforced in GroupMembership#validate. 
      # The way that sponsored groups work is that a SponsorAdmin puts SponsorMembers into groups...even non-public groups...no invite required.
      # So to skip the whole invite necessicity, I am currently using instance_eval to change how Profile#has_received_invitation? works for this specific instance of Profile (member)
      # I fully realize that providing this much documentation probably means this is a bad idea, an ugly hack and an overall Ruby tragedy.
      # However, I really don't want to mess with the GroupMembership#validate conditionals. They are very far reaching and the current override I need is limited to this specific scope.
      # Please direct all gripes and complaints to my personal email: markmcspadden@gmail.com
      if !@sponsor_group.is_public?
        @sponsor.instance_eval do
          alias :original_has_received_invitation? :has_received_invitation? 
          def has_received_invitation?(group)
            true
          end
        end
      
        GroupMembership.create!(:member => @sponsor, :group => @sponsor_group)
      
        @sponsor.instance_eval do
          alias :has_received_invitation? :original_has_received_invitation? 
        end
      else
        @sponsor_group.members << @sponsor
      end
      
      add_to_notices "#{@sponsor.full_name.titleize} has been added to #{@sponsor_group.name.titleize}"
    rescue
      add_to_errors "We couldn't add that user to the group :("
    end

    redirect_to sponsor_account_sponsor_groups_path(@sponsor_account)
  end

  def remove_sponsor
    begin
      @sponsor_account = SponsorAccount.find(params[:sponsor_account_id])
      @sponsor_group = @sponsor_account.groups.find(params[:id])
      @sponsor = @sponsor_account.sponsors.find(params[:profile][:id])
      GroupMembership.destroy_all(["group_id = ? and profile_id = ?", @sponsor_group.id, @sponsor.id ])
      Watch.destroy_all(["watchable_type = ? and watchable_id = ? and watcher_id = ?", 'Group', @sponsor_group.id, @sponsor.id])if @sponsor_group.is_private?
      add_to_notices "#{@sponsor.full_name.titleize} has been removed from #{@sponsor_group.name.titleize}"
    rescue
      add_to_errors "We couldn't remove that user from the group :("
    end
    redirect_to sponsor_account_sponsor_groups_path(@sponsor_account)
  end
  
  def transfer_ownership
    begin
      @sponsor_account = SponsorAccount.find(params[:sponsor_account_id])
      @sponsor_group = @sponsor_account.groups.find(params[:id])
      @sponsor = @sponsor_account.sponsors.find(params[:profile][:id])
      @sponsor_group.transfer_ownership_to!(@sponsor)
      add_to_notices "#{@sponsor_group.name.titleize}'s owner is now #{@sponsor.full_name.titleize}"
    rescue
      add_to_errors "We couldn't transfer the ownership to that user :("
    end
    redirect_to sponsor_account_sponsor_groups_path(@sponsor_account)
  end
end
