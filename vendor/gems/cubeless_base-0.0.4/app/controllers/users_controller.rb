class UsersController < ApplicationController
  allow_access_for :all => :user_admin

  def index
    @profiles = return_users(params)
    @roles = [['Any', '']]
    @roles.push(['Cubeless Admins', '0']) if current_profile.has_role?(Role::CubelessAdmin)
    @roles.push(['Report Admins', '1'], ['Content Admins', '2'],['Shady Admins', '3'],['User Admins', '4'],['Awards Admins', '7'])
    @roles.push(['Sponsor Admins', '8']) if current_profile.has_role?(Role::CubelessAdmin)
    @roles.push(['Direct Members', '5'])
    render :layout => 'user_admin_sub_menu'
  end
  
  def registration_details
    @user = User.find(params[:id])
    @profile = Profile.find_by_user_id(@user.id) # [@user.profile].flatten.compact.last
    @profile_registration_fields = @profile.profile_registration_fields(:include => [:site_registration_fields])
    render :layout => 'user_admin_sub_menu'    
  end

  def edit
    @user = User.find(params[:id])
    @profile = @user.profile
    render :layout => 'user_admin_sub_menu'
  end

  def new
    @user = User.new
    @profile = Profile.new
    render :layout => 'user_admin_sub_menu'
  end

  def create
    redirect_to users_path and return if params[:reset]
    @user = User.new
    @profile = Profile.new
    @profile.karma_points = params[:profile][:karma_points]
    @profile.attributes = params[:profile]
    @profile.roles = Role.find_all( *(params[:profile][:roles] || []).push(Role::DirectMember.id).map(&:to_i) )
    @profile.user = @user
    @user.attributes = params[:user]
    @user.login = params[:user][:login]
    @user.sync_exclude = true if @profile.has_role? Role::SponsorMember
    respond_to do |format|
      format.html {
        if @user.valid? && @profile.valid? && @user.save! && @profile.save!
          add_to_notices("User was successfully updated.")
          redirect_to users_path
        else
          add_to_errors([@user, @profile])
          render :action => :new, :layout => 'user_admin_sub_menu'
        end
      }
    end
  end

  def update
    redirect_to users_path and return if params[:reset]
    @user = User.find(params[:id])
    @profile = @user.profile
    @profile.karma_points = params[:profile][:karma_points]
    @profile.attributes = params[:profile]
    @profile.roles = Role.find_all( *(params[:profile][:roles] || []).push(Role::DirectMember.id).map(&:to_i) )
    @user.attributes = params[:user]
    @user.login = params[:user][:login]
    @user.sync_exclude = true if @profile.has_role? Role::SponsorMember
    respond_to do |format|
      format.html {
        if @user.valid? && @profile.valid? && @user.save! && @profile.save!
          add_to_notices("User was successfully updated.")
          redirect_to users_path
        else
          add_to_errors([@user, @profile])
          render :action => :edit, :layout => 'user_admin_sub_menu'
        end
      }
    end
  end

  def destroy
    user = User.find(params[:id])
    profile = user.profile
    profile.status = -1
    if profile.save
      add_to_notices("User has been queued for deletion.")
    else
      add_to_errors(profile)
    end
    respond_to do |format|
      format.html { redirect_to users_path }
      format.js { render :nothing => true }      
    end
  end

  def clear_lock
    u = User.find(params[:id])
    u.update_attributes('locked_until' => nil)
    audit_event(:user_unlocked,:target => u.profile)
    add_to_notices("User's account has been unlocked.")
    respond_to do |format|
      format.html { redirect_to users_path }
      format.js { render :nothing => true }      
    end
  end
  
  def activate
    u = User.find(params[:id])
    u.profile.update_attributes('status' => 1, 'visible' => 1)
    respond_to do |format|
      format.html { redirect_to users_path }
      format.js { render :nothing => true }
    end
  end
  
  def activate_on_login
    u = User.find(params[:id])
    u.profile.update_attributes('status' => 2)
    respond_to do |format|
      format.html { redirect_to users_path }
      format.js { render :nothing => true }
    end
  end

  def resend_welcome
    user = User.find(params[:id])
    user.generate_temp_crypted_password(7.days.from_now)
    user.profile.last_sent_welcome_at = Time.now
    user.save_without_validation
    Notifier.deliver_welcome(user)
    add_to_notices("Welcome email has been resent to #{user.email}")
    respond_to do |format|
      format.html { redirect_to users_path }
      format.js { render :nothing => true }      
    end
  end
  
  def resend_welcome_bulk
     if params[:sendcbToggle] then      
        params[:sendcbToggle].each_pair do |k,v|
          u = User.find(v) 
          p = u.profile
          Notifier.deliver_welcome(u)
          p.update_attribute :last_sent_welcome_at, Time.now
  	     end
     end
     redirect_to(never_logged_in_users_path)
  end
  
  def never_logged_in     
    @page_size=40
    params[:sql_include] = [:user]
    @profiles = return_users(params, "profiles.last_login_date IS NULL and users.email is not null")
    render :layout => 'user_admin_sub_menu'
  end

  @@user_sort_options = {
    "first_name" => "first_name", "last_name" => "last_name", "screen_name" => "screen_name", "email" => "users.email", "status" => "status", "visible" => "visible", "sync_exclude" => "users.sync_exclude", "last_sent_welcome_at" => "last_name",
    "first_name_reverse" => "first_name DESC", "last_name" => "last_name DESC", "screen_name" => "screen_name DESC", "email_reverse" => "users.email DESC", "status_reverse" => "status DESC", "visible" => "visible DESC", "sync_exclude" => "users.sync_exclude DESC", "last_sent_welcome_at_reverse" => "last_sent_welcome_at DESC"
  }

  private

  def return_users(query, condition=nil)
    # New will_paginate paging options
    # @page_size ||= 10    
    # options = {:page => default_paging(@page_size)}
    options = {}
    options.merge!(:page => params[:page])

    [:status, :visible].each { |x| ModelUtil.add_conditions!(options, ["#{x.to_s}=?",query[x]]) unless query[x].blank? }
    options[:order] = @@user_sort_options[params[:sort]] unless params[:sort].blank?

    options[:include] = query[:sql_include] if query.include?(:sql_include)  
     
    ModelUtil.add_conditions!(options, condition) if condition
    ModelUtil.add_conditions!(options, "profiles.roles like '%#{query[:role]}%'") unless query[:role].blank?
    ModelUtil.add_conditions!(options, "profiles.roles not like '%#{Role::SponsorMember.id}%'")
    ModelUtil.add_conditions!(options, "profiles.roles not like '%#{Role::CubelessAdmin.id}%'") unless current_profile.has_role?(Role::CubelessAdmin)
    ModelUtil.add_conditions!(options, "profiles.roles not like '%#{Role::SponsorAdmin.id}%'") unless current_profile.has_role?(Role::CubelessAdmin)
    ModelUtil.add_joins!(options, "join users on profiles.user_id = users.id")

    # Using will_paginate now!

    options.merge!(:page => params[:page] || 1)
    
    # query.include?(:name) ? Profile.find_by_full_name_login_or_screen_name(query[:name], options) : Profile.find(:all, options)
    if query.include?(:name)
      options.delete(:page)
      Profile.find_by_full_name_login_or_screen_name(query[:name], options).paginate(:per_page => 10, :page => params[:page])
    else
      Profile.paginate(options)
    end
    
    
    # filters = question_filters
    # filters.merge!(:page => params[:page])
    # @question_summaries = Question.company_questions(current_company.id, filters)
    # 
    # 
    # opts.delete(:summary)
    # opts.delete(:unscoped) 
    # ModelUtil.add_conditions!(opts, ["questions.company_id = ?", company_id] )
    # if opts.has_key?(:page)
    #   self.unscoped.paginate(opts)
    # else  
    #   self.unscoped.find(:all, opts)
    # end

  end

end