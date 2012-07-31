class NewsController < ApplicationController
  before_filter :set_post, :except => [:index]
  
  def index
    set_news
  end
  
  def post
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

private  
  def set_news
    if current_profile.sponsor?
      # scope to the sponsor's posts
      @news = current_profile.blog_posts.where(:blog_id => News.id).paginate(:page => params[:page])
    else
      @news = News.blog_posts.paginate(:page => params[:page])
    end    
  end

  def set_post
    @post = BlogPost.find(params[:id])
  end
  
  def update_post_attributes(attributes = [])
    @post.title = attributes[:title]
    @post.text = attributes[:text]
    @post.tagline = attributes[:tagline]
    @post.tag_list = attributes[:tag_list]
  end
end