class WatchesController < ApplicationController

  before_filter :set_profile
  skip_before_filter :require_auth, :only => :feed
  skip_before_filter :require_terms_acceptance, :only => :feed
  deny_access_for :all => :sponsor_member

  def index
    show
  end

  def show
    return redirect_to @profile unless(@profile == current_profile)
    options = {:order => 'created_at desc'}
    if params[:action]=='show'
      watch = Watch.find(params[:id])
      @filter_set = "Watch_#{watch.watchable_type.downcase}"
      options.merge!(:conditions => ['watch_events.watchable_type=? and watch_events.watchable_id=?',watch.watchable_type,watch.watchable_id])
    end
    options.merge!(:conditions => "watch_events.watchable_type='Profile'") if params[:action]=='profiles'
    options.merge!(:conditions => "watch_events.watchable_type='Group'") if params[:action]=='groups'
    @events = @profile.watch_events(watch_filters(options))
    init_watch_list
    render :layout => '_my_stuff', :template => 'watches/show'
  end

  def groups
    @filter_set = 'Watch_group'
    show
  end

  def profiles
    @filter_set = 'Watch_profile'
    show
  end

  def feed
    @events = @profile.watch_events(:order => 'created_at desc')
    render :action => 'feed.rxml', :layout => false
  end

  def create
    model = find_by_type_and_id(params[:type], params[:id])
    watch = Watch.create(:watcher => current_profile, :watchable => model)
    respond_to do |format|
      format.html { redirect_to :back }
      format.json { render :text => watch.to_json }
    end
  end

  def destroy
    watch = Watch.find(params[:id])
    watch.destroy if watch.watcher == current_profile
    init_watch_list
    render :update do |page|
      page.redirect_to profile_watches_path(@profile)
    end
  end

  private

  def set_profile
    @profile = Profile.find(params[:profile_id])
  end

  def init_watch_list
    @profile_watches = @profile.watches.find(:all, :conditions => "watchable_type='Profile'", :joins => "join profiles p on p.id=watches.watchable_id", :order => "p.screen_name")
    @group_watches = @profile.watches.find(:all, :conditions => "watchable_type='Group'", :joins => "join groups g on g.id=watches.watchable_id", :order => "g.name")
  end

end