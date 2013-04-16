class GroupPostsController < ApplicationController

  layout 'group'
  
  before_filter :group_up_and_protect_privates
  before_filter :find_booth_details, :except => [:destroy, :create_reply]
  
  def index
    return redirect_to(group_path(@group)) unless @group.is_member?(current_profile) || current_profile.has_role?(Role::ShadyAdmin)
    @group_post = GroupPost.new
    @group_posts = @group.group_posts.all.paginate(:page => params[:page], :per_page => 1)
    if @group.is_sponsored?
      render :layout => '/layouts/sponsored_group'
    end
  end

  def create
    @group = current_profile.groups.find(params[:group_id])
    @group_post = @group.group_posts.build(params[:group_post].merge!(:profile => current_profile))
    if @group_post.save
      redirect_to group_group_posts_path(@group)
    else
      @group_posts = @group.group_posts.all(:page => default_paging(4))
      add_to_errors @group_post
      render :template => 'group_posts/index', :layout =>  @group.is_sponsored? ? '/layouts/sponsored_group' : '/layouts/group'
    end
  end
  
  def destroy
    group_post = GroupPost.find(params[:id])
    return respond_not_authorized unless group_post.authored_by?(current_profile) || group_post.group.editable_by?(current_profile)
    if group_post.destroy
      render :update do |page|
        @group = group_post.group
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
        page.select(".group_post.#{group_post.id}").each do |div|
        page.visual_effect :highlight, div, :duration =>  1, :startcolor => "#666666"
    end
        page.delay 1 do
          page[:group_posts].replace_html :partial =>'group_posts/group_post', :collection => @group.group_posts.all(:page => default_paging(4))
        end
      end
    end
     if @group.is_sponsored?
      render :layout => '/layouts/sponsored_group'
    end
  end

  def show
    @group_post = GroupPost.new
    post = GroupPost.find(params[:id])
    @group_posts = [post]
    @group = post.group
    render :template => 'group_posts/index'
    # redirect_to group_talk_group_path GroupPost.find(params[:id]).group
  end

  def create_reply
    @group_post = GroupPost.find(params[:id])
    @group = @group_post.group
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
    comment = Comment.new(:profile => current_profile, :owner => @group_post, :owner_type => 'GroupPost', :text => params[:comment][:text])
    respond_to do |format|
      format.html {
        add_to_errors(comment) unless comment.save
        redirect_to :back
      }
    end
     if @group.is_sponsored?
      render :layout => '/layouts/sponsored_group'
     end
  end

  private

  def group_up_and_protect_privates
    @group = Group.find_by_id(params[:group_id])
    private_group_protection_needed
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
