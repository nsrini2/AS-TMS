class NewsController < ApplicationController
  before_filter :set_post, :except => [:index]
  
  def index
    set_news
  end
  
  def post
    render :show
  end
  
  def edit_post
    render :text => "edit post #{@post.id}" 
  end
  
  def update_post
    render :text => "update post #{@post.id}"
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
end