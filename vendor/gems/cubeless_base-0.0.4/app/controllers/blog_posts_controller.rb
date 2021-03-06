class BlogPostsController < ApplicationController
  skip_before_filter :require_auth, :only => [:index]
  skip_before_filter :require_terms_acceptance, :only => [:index]
  before_filter :set_owner, :except => [:show, :rate, :new_comment, :destroy]
  before_filter :check_for_news_post, :only => [:show]
  before_filter :clean_tags, :only => [:create, :update]
  deny_access_for :all => :sponsor_member, :when => lambda{|c| c.instance_variable_get(:@owner).is_a?(Profile)}

  def new
    return redirect_to(url_for([@owner, :blog])) if !bloggable?
    @blog_post = BlogPost.new
    @blog = @owner.blog
    render :template => 'blog_posts/new', :layout => @owner.is_a?(Group) ? (@owner.is_sponsored? ? 'sponsored_group' :'group') : '_my_stuff'
  end

  def create
    return redirect_to(url_for([@owner, :blog])) if !bloggable?
    @blog_post = BlogPost.new(params[:blog_post])
    @blog_post.profile = current_profile
    @blog_post.blog = @owner.blog
    if params[:commit]
      if @blog_post.save
        add_to_notices('Your blog post was created!')
        redirect_to @blog_post
      else
        @blog = @owner.blog
        add_to_errors(@blog_post)
        render :template => 'blog_posts/new', :layout => @owner.is_a?(Group) ? (@owner.is_sponsored? ? 'sponsored_group' :'group') : '_my_stuff'
      end
    elsif params[:preview]
      @blog = @owner.blog
      @preview_blog_post = @blog_post
      render :template => 'blog_posts/new', :layout => @owner.is_a?(Group) ? (@owner.is_sponsored? ? 'sponsored_group' :'group') : '_my_stuff'
    else
      redirect_to [@owner, :blog]
    end
  end

  def show
    @blog = BlogPost.find_by_id(params[:id]).blog
    @owner = @blog.owner
    
    if @blog.company?
      redirect_to view_context.companies_blog_blog_post_path(params[:id])
    else
      unless private_group_protection_needed(@owner)
        @blog_posts = @blog.blog_posts.where(:id => params[:id])
        @blog_posts = @blog_posts.page(params[:page])
        @archives = @blog.archived_posts
        instance_variable_set("@#{@owner.class.name.downcase}", @owner)
        @blog_posts[0].increment_post_views! unless @owner==current_profile
        if @owner.is_a?(Group)
          @group = @owner
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
          render :template => 'blogs/show', :layout => @owner.is_sponsored? ? 'sponsored_group' :'group'
         else
          render :template => 'blogs/show', :layout => '_my_stuff'
        end
      end
    end
  end

  def edit
    @blog_post = BlogPost.find(params[:id])
    @blog = @blog_post.blog
    @owner = @blog.owner
    if is_editable?(@blog_post)
      if @owner.is_a?(Group)
          @group = @owner
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
         render :template => 'blog_posts/edit', :layout => @owner.is_sponsored? ? 'sponsored_group' :'group'
         else
          render :template => 'blog_posts/edit', :layout => '_my_stuff'
      end
    end
  end

  def update
    @blog_post = BlogPost.find(params[:id])
    @blog = @blog_post.blog
    @owner = @blog.owner
     if @owner.is_a?(Group)
        @group = @owner
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

      if is_editable?(@blog_post)
        if params[:commit]
          if @blog_post.update_attributes(params[:blog_post])
            add_to_notices('Blog post successfully updated!')
            redirect_to @blog_post
          else
            add_to_errors(@blog_post)
            render :template => 'blog_posts/edit', :layout => @owner.is_a?(Group) ?  (@owner.is_sponsored? ? 'sponsored_group' :'group') : '_my_stuff'
          end
        elsif params[:preview]
          @blog_post.title = params[:blog_post][:title]
          @blog_post.text = params[:blog_post][:text]
          @blog_post.tag_list = params[:blog_post][:tag_list]
          @blog = @blog_post.blog
          @preview_blog_post = @blog_post
          render :template => 'blog_posts/edit', :layout => @owner.is_a?(Group) ? (@owner.is_sponsored? ? 'sponsored_group' :'group') : '_my_stuff'
        else
          redirect_to @blog_post
        end
    end
  end

  def destroy
    blog_post = BlogPost.find(params[:id])
    return unless blog_post.deletable_by?(current_profile)
    blog_owner = blog_post.blog.owner
    owner_path = blog_owner.is_a?(Profile) ? profile_blog_path(blog_owner) : group_blog_path(blog_owner)
    blog_post.destroy
    respond_to do |format|
      format.json { render :text => "{\"redirect\" : \"#{owner_path}\"}" }
      format.html { redirect_to owner_path }
    end
  end

  def rate
    blog_post = BlogPost.find(params[:id])
    blog_post.rate(params[:rating].to_i, current_profile)
    blog_post.save(false) #some old posts don't have tags which are now required
    blog_post.reload
    respond_to do |format|
      format.html { redirect_to :back }
      format.js { render(:partial => 'blog_posts/rating', :layout => false, :locals => { :blog_post => blog_post } ) }
    end
  end

  def new_comment
    @blog_post = BlogPost.find(params[:id])
    comment = Comment.new(:profile => current_profile, :owner => @blog_post, :owner_type => 'BlogPost', :text => params[:comment][:text])
    if comment.save
      redirect_to "#{blog_post_path(@blog_post)}#comment_#{comment.id}"
    else
      add_to_errors(comment)
      redirect_to blog_post_path(@blog_post) + "#{'?comment='+params[:comment][:text] unless params[:comment][:text].blank?}" + "#new_comment"
    end
  end

 private

  def check_for_news_post
    @post = BlogPost.unscoped.find(params[:id])
    if @post.news?
      redirect_to news_post_path(@post) and return
    end
  end

  def set_owner
    @owner = parent
    find_booth_details if @owner.is_a?(Group) && @owner.is_sponsored?
  end

  def bloggable?
    (@owner.is_a?(Group) ? @owner.is_member?(current_profile) : current_profile == @owner)
  end
  
  def clean_tags
    params[:blog_post][:tag_list].tr!("'","")
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
