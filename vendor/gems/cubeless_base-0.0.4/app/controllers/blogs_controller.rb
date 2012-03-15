class BlogsController < ApplicationController
  before_filter :set_owner
  deny_access_for :all => :sponsor_member, :when => lambda{|c| c.instance_variable_get(:@owner).is_a?(Profile)}

  def show
    @blog = @owner.blog
    unless private_group_protection_needed(@owner)
      Visitation.add_visitor_for(@owner,current_profile)
      @blog_posts = @blog.blog_posts.page(params[:page])
      if params[:tag]
        @blog_posts = @blog_posts.where("cached_tag_list LIKE ?", "%#{params[:tag]}%")
      end
      if params[:date]
        @blog_posts = @blog_posts.where("created_at_year_month = ?", "#{params[:date]}")
      end
      if @owner.is_a?(Profile) && @owner == current_profile && @blog_posts.blank?
        redirect_to url_for([@owner, :blog, :posts])+'/new'
      else
        render :layout => @owner.is_a?(Group) ? 'group': '_my_stuff'
      end
    end
  end

  protected
  def set_owner
    owner = parent
    @owner = [owner].flatten.first
  end

end