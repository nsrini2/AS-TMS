class CommentsController < ApplicationController
  before_filter :current_company, :set_selected_tab, :set_owner
  layout "_company_tabs"
  
  def index
    render :text => "app/controllers/companies/companies_answers_controller.rb::index"
  end
  
  def show
    
  end
  
  def new
  end
  
  def create
    return unless @owner
    comment = Comment.new(:text => params[:comment][:text], :owner => @owner, :author => current_profile)
    if comment.save
      flash[:notice]= "Comment Saved!"
    else
      flash[:notice]= "There was an error saving your comment."
    end 
    redirect_to companies_blog_blog_post_path(@owner) 
  end
  
  def edit
    # done in comments_controller
  end
  
  def update
    # done in comments_controller  
  end
  
  def destroy
    # done in comments_controller
  end

private
  def set_selected_tab
    @company_blog_tab_selected = "selected"
  end
  
  def set_owner
    if params[:blog_post_id]
      @owner = BlogPost.find_by_id(params[:blog_post_id])
    end  
  end
end