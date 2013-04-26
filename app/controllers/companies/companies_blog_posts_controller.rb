class BlogPostsController < ApplicationController
  before_filter :current_company, :set_selected_tab
  layout "_company_tabs"
  
  def index
    @owner = current_company
    @blog = current_company.blog
    @blog_posts = @blog.blog_posts
    if params[:tag]
      @blog_posts = @blog_posts.where("cached_tag_list LIKE ?", "%#{params[:tag]}%")
    end
    if params[:date]
      @blog_posts = @blog_posts.where("created_at_year_month = ?", "#{params[:date]}")
    end
    @blog_posts = @blog_posts.page(params[:page])
  end
  
  def show
    @owner = current_company
    @blog = @owner.blog
    @blog_post = @blog.blog_posts.find_by_id(params[:id])
  end
  
  def new
    @blog = current_company.blog
    @blog_post =  @blog.blog_posts.new()
    @blog_post.creator = current_profile
  end
  
  def create
    @owner = current_company
    @blog = @owner.blog
    @blog_posts = @blog.blog_posts
    @blog_post = @blog.blog_posts.new(params[:blog_post])
    @blog_post.profile = current_profile
    if params[:commit]
      if @blog_post.save
        add_to_notices('Your blog post was created!')
        render :action => :show
      else
        add_to_errors(@blog_post)
        render :action => 'new'
      end
    elsif params[:preview]
      @preview_blog_post = @blog_post
      render :action => 'new'
    else
      # this is where you go if you hit cancel
      render :action => :show
    end
  end
  
  def edit
    @owner = current_company
    @blog = @owner.blog
    @blog_post = @blog.blog_posts.find(params[:id])
  end
  
  def update
    @owner = current_company
    @blog = @owner.blog
    @blog_posts = @blog.blog_posts
    @blog_post = @blog.blog_posts.find(params[:id])
    if params[:commit]
      if @blog_post.update_attributes(params[:blog_post])
        add_to_notices('Your blog post was updated!')
        render :action => :show
      else
        add_to_errors(@blog_post)
        render :action => 'edit'
      end
    elsif params[:preview]
      @blog_post.attributes = params[:blog_post]
      @preview_blog_post = @blog_post
      render :action => 'edit'
    else
      # this is where you go if you hit cancel
      render :action => :show
      # redirect_to [@owner, :blog]
    end
  end
  
  def destroy
    render :text => "DESTROYED"
  end

private
  def set_selected_tab
    @company_blog_tab_selected = "selected"
  end
end