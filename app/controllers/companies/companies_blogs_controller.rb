class Companies::BlogsController < ApplicationController
  before_filter :current_company, :set_selected_tab
  layout "_company_tabs"
  
  def index
    # @blog = Group.find(8).blog
    @blog = current_company.blog
    @blog_posts = @blog.blog_posts
    # @blog_posts.pop
    render :action => :show
  end
  
  def show
  end
  
  def new
    @blog_post = current_company.blog.blog_posts.new({:profile_id => current_profile.id})
  end
  
  def create 
  end
  
  def edit
  end
  
  def update
  end
  
  def destroy
  end

private
  def set_selected_tab
    @company_blog_tab_selected = "selected"
  end
  
end