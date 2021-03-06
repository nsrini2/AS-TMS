class NewsController < ApplicationController
  include ActionView::Helpers::TextHelper # for tuncate
  
  before_filter :set_post, :except => [:index, :follow]
  before_filter :set_news, :only => [:index, :show]
  
  def index
    NewsFollower.visit(current_user)
    @top_posts = News.top_posts(5)
  end
  
  def post
    @post.increment_post_views!
    @selected_tags = @post.tags.map {|t| t.name}
    @selected_date = @post.created_at_year_month.to_s
    @post.creator.extend AgentStreamExtensions::Sample
    @selected_source = @post.creator.sample(:description)
    @tweet_text = "I found this great article: #{truncate(@post.title, :length => 50, :omission => '...')} "
    render :show
  end
  
  def edit_post
    render :show unless @post.editable_by? current_profile  
  end
  
  def update_post
    if @post.editable_by? current_profile
      if params[:preview].present?
        update_post_attributes(params[:blog_post])
        @preview_blog_post = true
        render :edit_post
      elsif params[:commit].present?
        update_post_attributes(params[:blog_post])
        if @post.save
          flash[:notice] = "#{@post.title} has been updated."
          render :show
        else  
          flash[:notice] = "Unabel to save post: #{@post.errors.full_messages}"
          render :edit_post
        end
      else # user canceled changes
        render :show   
      end
    else
      # this profiel cannot edit this post
      flash[:notice] = "This profile lacks the privileges to update this post."
      render :show
    end
  end
  
  def destroy
    if @post.deletable_by? current_profile
      @post.destroy
      flash[:notice] = "Post #{@post.title} has been deleted."
    else
      flash[:notice] = "This profile lacks the privileges to delete this post."
    end     
    set_news
    render :action => "index"
  end

  def follow
    if NewsFollower.following?(current_profile)
      NewsFollower.find_by_profile_id(current_profile.id).destroy
    else
      follower = NewsFollower.create(:profile_id => current_profile.id)
    end
    link = view_context.link_to_follow_news
    render :text => link
  end

private  
  def set_news
    @selected_tags, @selected_date, @selected_source = ""
    @posts_header = "Recent News"
    if current_profile.sponsor?
      # scope to the sponsor's posts
      @news = current_profile.blog_posts.where(:blog_id => News.id).paginate(:page => params[:page])
    else
      @news = News.blog_posts.paginate(:page => params[:page])
    end
    if params[:tag]
      @selected_tags = params[:tag]
      @posts_header = @selected_tags
      @news = @news.where("cached_tag_list LIKE ?", "%#{@selected_tags}%")
    end
    if params[:date]
      @selected_date = params[:date]
      @news = @news.where("created_at_year_month = ?", @selected_date)
      @selected_date.extend AgentStreamExtensions::String
      @posts_header = @selected_date.to_month_year
    end
    if params[:source]
      begin
        @selected_source = params[:source].to_i
        source_rss = RssFeed.active.find_by_id(@selected_source)
        source_rss.extend AgentStreamExtensions::Sample
        @posts_header = source_rss.sample :description
      rescue
        @selected_source = 0
      ensure
        @news = @news.where(:creator_type => "RssFeed", :creator_id => @selected_source )
      end
    end
  end

  def set_post
    @post = News.blog_posts.find(params[:id])
  end
  
  def update_post_attributes(attributes = [])
    @post.title = attributes[:title]
    @post.text = attributes[:text]
    @post.tagline = attributes[:tagline]
    @post.tag_list = attributes[:tag_list]
  end
  

end