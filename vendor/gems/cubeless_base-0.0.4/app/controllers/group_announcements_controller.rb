class GroupAnnouncementsController < ApplicationController
  before_filter :init_group_announcement

  def show
    render :template => 'group_announcements/_group_announcement_form', :layout => @group.is_sponsored? ? '/layouts/sponsored_group_manage_sub_menu' : 'layouts/group_manage_sub_menu'
  end

  def update
    if params[:commit] == 'Remove'
      params[:group_announcement][:content] = ''
      params[:group_announcement][:start_date] = ''
      params[:group_announcement][:end_date] = ''
    end
    @group_announcement.update_attributes!(params[:group_announcement])
    redirect_to group_announcement_path
  end

  protected
  def init_group_announcement
    @group = Group.find(params[:group_id])
    find_booth_details if @group.is_sponsored?
    redirect_to group_path(@group) and return unless is_editable?(@group)
    @group_announcement = @group.group_announcement || GroupAnnouncement.create!(:group => @group)
  end

  def find_booth_details
    @group = Group.find(params[:group_id])
    @group_links = @group.group_links.all
     max_id = Group.count_by_sql("select min(profile_id) from (select profile_id from group_memberships where group_id = #{@group.id} order by profile_id desc limit 200) as x")
    @booth_members = @group.members.all(:conditions => "profiles.id >= #{rand(max_id)+1}", :limit => 20).to_a.sort! { |a,b| rand(3)-1 }
    @group_blog_tags=TagCloud.tagcloudize(@group.blog.booth_tags.map{|x|x.name + " "})
    if @group_blog_tags.count > 0
      @group_blog_tags.sort!{|a,b|a[:count]<=>b[:count]}
      @minTagOccurs=@group_blog_tags.first[:count]
      @maxTagOccurs=@group_blog_tags.last[:count]
    end
    source=@group.booth_twitter_id
    if !source.nil?
      begin
       @twitter_feed=Twitter.user_timeline("#{source}").first.text
       @twitter_user_name=Twitter.user("#{source}").name
       @twitter_user_handle="@"+Twitter.user("#{source}").screen_name
      rescue => e
       Rails.logger.info("Twitter error: " + e.message)
      end
    end
  end
end
