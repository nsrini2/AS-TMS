class BlogsController < ApplicationController
  before_filter :set_owner
  before_filter :find_booth_details
  deny_access_for :all => :sponsor_member, :when => lambda{|c| c.instance_variable_get(:@owner).is_a?(Profile)}

  def show
    @blog = @owner.blog
    unless private_group_protection_needed(@owner)
      Visitation.add_visitor_for(@owner,current_profile)
      @blog_posts = @blog.blog_posts.paginate(:page => params[:page], :per_page => 5)
      if params[:tag]
        @blog_posts = @blog_posts.where("cached_tag_list LIKE ?", "%#{params[:tag]}%")
      end
      if params[:date]
        @blog_posts = @blog_posts.where("created_at_year_month = ?", "#{params[:date]}")
      end
      if @owner.is_a?(Profile) && @owner == current_profile && @blog_posts.blank?
        redirect_to url_for([@owner, :blog, :blog_posts])+'/new'
      else
        render :layout => @owner.is_a?(Group) ? (@owner.is_sponsored? ? 'sponsored_group' :'group') : '_my_stuff'
      end
    end
  end

  protected
  def set_owner
    owner = parent
    @owner = [owner].flatten.first
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
       @twitter_feed=Twitter.user_timeline("#{source}").first.text
       @twitter_user_name=Twitter.user("#{source}").name
       @twitter_user_handle="@"+Twitter.user("#{source}").screen_name
    end
  end

end
