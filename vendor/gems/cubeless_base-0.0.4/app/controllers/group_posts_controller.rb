class GroupPostsController < ApplicationController

  layout 'group'
  
  before_filter :group_up_and_protect_privates
  
  def index
    return redirect_to(group_path(@group)) unless @group.is_member?(current_profile) || current_profile.has_role?(Role::ShadyAdmin)
    @group_post = GroupPost.new
    @group_posts = @group.group_posts.all(:page => default_paging(4))
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
      render :template => 'group_posts/index'
    end
    if @group.is_sponsored?
      render :layout => '/layouts/sponsored_group'
    end
  end
  
  def destroy
    group_post = GroupPost.find(params[:id])
    return respond_not_authorized unless group_post.authored_by?(current_profile) || group_post.group.editable_by?(current_profile)
    if group_post.destroy
      render :update do |page|
        @group = group_post.group
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
     if @group.is_sponsored?
      render :layout => '/layouts/sponsored_group'
    end
    # redirect_to group_talk_group_path GroupPost.find(params[:id]).group
  end

  def create_reply
    @group_post = GroupPost.find(params[:id])
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

end
