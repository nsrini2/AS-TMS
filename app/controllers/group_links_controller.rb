require 'will_paginate/array'

class GroupLinksController < ApplicationController
respond_to :html, :json

 before_filter :find_booth_details

 def index
    @useful_links = GroupLink.find(:all,:conditions => ["group_id =?",@group.id]).paginate(:page => params[:group_links_page], :per_page => 10)
    render :layout => '/layouts/sponsored_group_manage_sub_menu'
 end


 def new
     render :layout => '/layouts/sponsored_group_manage_sub_menu'
 end

  def create
    @group_link=GroupLink.new(params[:group_link])
    @group_link.group_id=params[:group_id]
    if @group_link.save
       flash[:notice] = "A new booth link was created!"
       redirect_to group_group_links_path(@group), :group_links_page => (@group.group_links.count/10.to_f).ceil
     else
       flash[:errors] = @group_link.errors
       render :action => "new", :layout => '/layouts/sponsored_group_manage_sub_menu'
    end
  end


   def destroy
    @group_link=GroupLink.find(params[:id])
    @group_link.destroy
    respond_to do |format|
      format.html { redirect_to :back }
    end
  end

  def find_booth_details
    @group = Group.find(params[:group_id])
    @group_blog_tags=@group.blog.blog_posts.tag_counts
    @group_links = @group.group_links.all
     max_id = Group.count_by_sql("select min(profile_id) from (select profile_id from group_memberships where group_id = #{@group.id} order by profile_id desc limit 200) as x")
    @booth_members = @group.members.all(:conditions => "profiles.id >= #{rand(max_id)+1}", :limit => 20).to_a.sort! { |a,b| rand(3)-1 }
  end
end