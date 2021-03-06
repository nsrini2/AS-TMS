class SponsorMembersController < ApplicationController
  layout 'sponsor_accounts_sub_menu'

  allow_access_for :all => :sponsor_admin

  def index
    @sponsor_account = SponsorAccount.find(params[:sponsor_account_id])
    @sponsors=@sponsor_account.sponsors.paginate(:page => params[:page], :per_page => 5)
  end

  def create
    @user = User.new(params[:user])
    @user.login = params[:user][:login]
    @user.email = params[:user][:email]
    @user.sync_exclude = true
    @profile = Profile.new(params[:profile])
    @profile.add_roles Role::SponsorMember
    @profile.karma_points = params[:profile][:karma_points]
    @profile.user = @user
    @sponsor_account = SponsorAccount.find( params[:sponsor_account_id] )
    @profile.sponsor_account = @sponsor_account
    begin
      Profile.transaction do
        raise 'fail' unless @user.valid? && @profile.valid?
        @user.save! && @profile.save!
        
        # MM2: Associating this way cause problems with members that had different logins but the same screen name
        # At this time, unique screen names are not required :/
        # Added @profile.spaonsor_account = @sponosor_account above to handle the association
        #
        # @sponsor_account.sponsors << @profile
        # @sponsor_account.save!
      end
      add_to_notices "#{@profile.full_name.titleize} has been saved"
    rescue
      add_to_errors [@profile, @user]
      return render(:action => 'new')
    end
    if @sponsor_account.groups.blank?
      redirect_to new_sponsor_account_sponsor_group_path(@sponsor_account)
    else
      redirect_to sponsor_account_sponsor_members_path(@sponsor_account)
    end
  end
  
  def update
    @profile = Profile.include_sponsor_members.find( params[:id] )
    @profile.karma_points = params[:profile][:karma_points]
    @user = @profile.user
    @user.login = params[:user][:login]
    @user.email = params[:user][:email]
    
    if @profile.update_attributes( params[:profile] ) && @user.update_attributes( params[:user] )
      add_to_notices "#{@profile.full_name.titleize} has been saved"
      redirect_to sponsor_account_sponsor_members_path(@profile.sponsor_account)
    else
      add_to_errors [@profile, @user]
      return render(:action => 'edit')
    end
  end

  def new
    @sponsor_account = SponsorAccount.find( params[:sponsor_account_id] )
    @profile = Profile.new
    @user = User.new
  end
  
  def edit
    @profile = Profile.include_sponsor_members.find( params[:id] )
    @user = @profile.user
  end
  
  def add_group
    begin
      @sponsor_account = SponsorAccount.find(params[:sponsor_account_id])
      @sponsor_member = @sponsor_account.sponsors.find(params[:id])
      @group = @sponsor_account.groups.find(params[:group][:id])
      @sponsor_member.groups << @group
      add_to_notices "#{@sponsor_member.full_name.titleize} has been added to #{@group.name.titleize}"
    rescue
      add_to_errors "We couldn't add that user to the group :("
    end

    redirect_to sponsor_account_sponsor_members_path(@sponsor_account)
  end

  def remove_group
    begin
      @sponsor_account = SponsorAccount.find(params[:sponsor_account_id])
      @sponsor_member = @sponsor_account.sponsors.find(params[:id])
      @group = @sponsor_account.groups.find(params[:group][:id])
    
      GroupMembership.destroy_all(["group_id = ? and profile_id = ?", @group.id, @sponsor_member.id ])
      Watch.destroy_all(["watchable_type = ? and watchable_id = ? and watcher_id = ?", 'Group', @group.id, @sponsor_member.id])if @group.is_private?
      add_to_notices "#{@sponsor_member.full_name.titleize} has been removed from #{@group.name.titleize}"
    rescue
      add_to_errors "We couldn't remove that user from the group :("
    end

    redirect_to sponsor_account_sponsor_members_path(@sponsor_account)
  end

  def reset_password
    @sponsor_member = Profile.include_sponsor_members.find( params[:id] )
    if request.post?
      if params[:commit] == 'Yes'
        user = @sponsor_member.user
        retrieval = Retrieval.new(:item => "password", :login => user.login)
        if retrieval.valid? and Notifier.deliver_retrieval(retrieval) && user.update_attribute(:crypted_password, nil)
          add_to_notices("This user's password has been reset")
        else
          add_to_errors(retrieval)
        end
      end
      redirect_to sponsor_account_sponsor_members_path(@sponsor_member.sponsor_account)
    end
  end

  def unlock
    @sponsor_member = Profile.include_sponsor_members.find( params[:id] )
    if request.post? 
      if params[:commit] == 'Yes'
        user = @sponsor_member.user
        user.update_attributes('locked_until' => nil)
        audit_event(:user_unlocked, :target => user.profile)
      end
      redirect_to sponsor_account_sponsor_members_path(@sponsor_member.sponsor_account)
    end
  end
end
