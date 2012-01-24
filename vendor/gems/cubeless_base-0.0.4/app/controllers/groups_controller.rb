class GroupsController < ApplicationController
  
  before_filter :init_group, :except => [:create, :new]
  
  allow_access_for :destroy => :shady_admin
  deny_access_for :show => :sponsor_member, :when => lambda{ |c| !c.instance_variable_get(:@group).is_member?(c.current_profile) }
  deny_access_for [:new, :create, :quit] => :sponsor_member
  
  before_filter :add_or_update_visitor, :only => [:show,:members]
  before_filter :private_group_protection_needed, :only => [:join, :members, :help_answer]
  
  layout 'group'

  def index
    redirect_to groups_explorations_path
  end

  def edit
    render :layout => 'group_manage_sub_menu'
  end

  def update
    if is_editable?(@group)
      params[:group][:last_updated_by] = current_profile.id
      @group.update_attributes( params[:group] )
      if params[:asset] && params[:asset][:uploaded_data] && !params[:asset][:uploaded_data].blank?
        create_or_update_group_photo
      end
      respond_to do |format|
        format.html { 
          add_to_notices "Group details have been saved!"
          redirect_to edit_group_path(@group)
        }
        format.json { render :text => @group.to_json }
      end
    end
  end

  def notes
    respond_to do |format|
      format.xml{
        opts = {}
        opts[:limit] = params[:limit].to_i if params[:limit]
        @notes = @group.notes.allow_group_member_or_sender_or_admin_to_see_all_for_receiver(current_profile, @group).find(:all,opts)
        render :template => 'notes/show', :layout => false
      }
    end
  end

  def mass_mail
    if is_editable?(@group)
      @mailer = MassMail.new unless request.post?
      if request.post?
        @mailer = MassMail.new(params[:mailer])
        if @mailer.valid?          
          @group.delay.send_mass_mail(current_profile.id, @mailer.subject, @mailer.body, :test_enabled => params[:test_enabled])
                    
          add_to_notices "Email is being sent to #{params[:test_enabled] ? current_profile.email : 'all members of the group'}."
        else
          add_to_errors @mailer
        end
      end
      render :layout => 'group_manage_sub_menu'
    end
  end

  def new
    if current_profile.num_group_slots_remaining < 1
      add_to_errors "You have no more unused group slots available."
      return redirect_to(groups_explorations_path)
    else
      @group = Group.new
      respond_to do |format|
        format.js { render(:template => 'groups/new', :layout=> '/layouts/_popup') }
        format.html { render :layout => false }
      end
    end
  end

  def create
    # MM2: Old Group.crate override syntax
    # @group = Group.create(params[:group], current_profile)
    @group = Group.new(params[:group])
    @group.owner = current_profile
    @group.save
    
    respond_to do |format|
      format.json {
        if @group.errors.size > 0
          add_to_errors(@group)
          render(:text => { :errors => flash[:errors] }.to_json)
          flash[:errors] = nil
        else
          if !@group.is_public?
            @group.make_owner_moderator!
          end
          
          add_to_notices "Group successfully created"
          render(:text => @group.to_json)
        end
      }
      # TODO: Turn this back to using the json response...
      format.html {
        if @group.errors.size > 0
          redirect_to groups_explorations_path, :notice => "There was an ERROR in saving this group: <br/><br/>#{@group.errors.full_messages.join("<br/><br/>")}"
        else
          redirect_to group_path(@group)
        end
      }
    end
  end

  def show
    render :action => 'group'
  end

  def stream
    render :partial => 'groups/event_stream'
  end

  def members
    max_id = Group.count_by_sql("select min(profile_id) from (select profile_id from group_memberships where group_id = #{@group.id} order by profile_id desc limit 200) as x")
    @members = @group.members.all(:conditions => "profiles.id >= #{rand(max_id)+1}", :limit => 200).to_a.sort! { |a,b| rand(3)-1 }
    @invitation_requests = GroupInvitationRequest.find(:all, :conditions => "group_id = #{@group.id}")
    @invitations_pending = GroupInvitation.find(:all, :conditions => "group_id = #{@group.id}")
  end

  def select_member
    respond_to do |format|
      format.js { render :partial => 'groups/member_card', :locals => { :member => @group.members.find(params[:selected]), :group => @group } }
    end
  end

  def help_answer
    redirect_to group_path(@group) and return if @group.is_private?
    # SSJ FIX
    # @referred_questions = @group.questions_referred_to_me.find(:all, :summary => true, :referral_owner => @group, :order => 'questions.created_at desc', :page => {:size => 5, :current => params[:referred_questions_page]})
    @referred_questions = []
  end

  def moderators
    redirect_to group_path(@group) and return unless @group.owner == current_profile
    @selected_option = case @group.moderators.count
      when 0: 'moderators_all'
      when 1: @group.moderators.include?(@group.owner) ? 'moderators_owner' : 'moderators_select'
      else 'moderators_select'
    end
    @selected_option = "moderators_select" if params[:q]
    @moderators = @group.moderators
    @non_moderators = non_mods if @selected_option == 'moderators_select'
    render :layout => 'group_manage_sub_menu'
  end

  def moderator_settings
    redirect_to group_path(@group) and return unless @group.owner == current_profile
    case params[:moderator_option]
      when 'moderators_all':  @group.make_unmoderated!
      when 'moderators_owner': @group.make_owner_moderator!
      when 'moderators_select'
        @group.make_owner_moderator!
        @moderators = @group.moderators
        @non_moderators = non_mods
    end
    render :partial => 'groups/moderator_options'
  end

  def assign_moderator
    return unless current_profile == @group.owner
    GroupMembership.find_by_group_id_and_profile_id(@group, params[:profile_id]).toggle!(:moderator)
    @non_moderators = non_mods
    @moderators = @group.moderators
    render :update do |page|
      page[:moderator_list].replace_html :partial => 'groups/member', :collection => @moderators.reject{|x| x.id==@group.owner_id }, :locals => {:is_moderator => true}
      page[:member_list].replace_html :partial => 'groups/member', :collection => @non_moderators, :locals => {:is_moderator => false}
    end
  end

  def ownership
   return redirect_to(group_path(@group)) unless (@group.owner == current_profile || current_profile.has_role?(Role::ShadyAdmin))
   @members = params[:q].blank? ? owner_transfer_results(@group) :owner_transfer_results(@group, params[:q])
   
   add_to_notices "Oops, we couldn't find a member with '#{params[:q]}' their name." if @members && @members.size.zero?
   respond_to do |format|
     format.html { render :layout => 'group_manage_sub_menu' }
   end
  end

  def assign_owner
    return unless current_profile == @group.owner || current_profile.has_role?(Role::ShadyAdmin)
    profile = @group.members.find_by_id(params[:profile_id])
    if profile
      @group.transfer_ownership_to!(profile)
    end
  end

  def non_mods
    opts = { :conditions => "moderator=0", :order => "screen_name", :page => default_paging }
    p = params[:q] || {}
    p.empty? ? @group.members.find(:all,opts) : @group.members.find_by_full_name(p,opts)
  end

  def filter_mods
    if is_editable?(@group)
      @non_moderators = non_mods
      render :partial => 'groups/member', :collection => @non_moderators, :locals => {:is_moderator => false}
    end
  end

  def join
    membership = GroupMembership.create({:profile_id => current_profile.id, :group_id => @group.id})
    if membership.errors.size > 0
      add_to_errors membership
      render(:text => { :errors => flash[:errors] }.to_json)
      flash[:errors] = nil
    else
      add_to_notices "You are now a member of this group."
      Watch.create(:watcher => current_profile, :watchable => @group) unless current_profile.is_watching?(@group)
      render(:text => membership.to_json)
    end
  end

  def quit
    GroupMembership.destroy_all(["group_id = ? and profile_id = ?", @group.id, current_profile.id ])
    Watch.destroy_all(["watchable_type = ? and watchable_id = ? and watcher_id = ?", 'Group', @group.id, current_profile.id])if @group.is_private?
    add_to_notices "You are no longer a member of #{@group.name}."
    respond_to do |format|
      format.html { redirect_to groups_profile_path(current_profile) }
    end
  end

  def destroy
    @group.destroy
    add_to_notices "Group successfully deleted"
  end

  def stats_summary
    redirect_to group_path(@group) and return unless is_editable?(@group)
    @stats = @group.stats
    render :layout => 'group_manage_sub_menu'
  end

  def remove_member
    return unless current_profile == @group.owner || current_profile.has_role?(Role::ShadyAdmin)
    @group.group_memberships.find_by_profile_id(params[:profile_id]).destroy
    Watch.destroy_all(["watchable_type = ? and watchable_id = ? and watcher_id = ?", 'Group', @group.id, params[:profile_id]])if @group.is_private?
    add_to_notices "Member was successfully removed from the group"
    respond_to do |format|
      format.js { render :nothing => true }
    end
  end

  
  def resend_all
     if is_editable?(@group)
         @group.invitations.each do | pending |
           pending.created_at = Time.now
           pending.save_without_validation!
         end
         redirect_to request.referer
     end
  end

  private

  def owner_transfer_results(group, name='')
    options = { :order => "screen_name", :page => default_paging }
    if group.is_sponsored?
      members = group.members.include_sponsor_members.find_by_full_name(name, options)
    else
      members = group.members.find_by_full_name(name, options)
    end
    return members
  end

  def init_group
    @group = Group.find_by_id(params[:id])
    redirect_to groups_explorations_path unless @group
  end

  def add_or_update_visitor
    @group.increment_group_views!
    Visitation.add_visitor_for(@group,current_profile)
    GroupMembership.update_last_visited!(@group.id,current_profile.id)
  end

  def create_or_update_group_photo
    if (@group.group_photo = GroupPhoto.new(params[:asset]))
      @group.update_attributes(:primary_photo => @group.group_photo)
    end
  end

  
end