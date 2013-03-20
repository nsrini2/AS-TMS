class GroupLinksController < ApplicationController
 allow_access_for :all => :sponsor_admin
 allow_access_for :all => :shady_admin

 before_filter :find_group


   def index
    @booth_links = @group.group_links.all
    render :template => 'group_links/group_links', :layout => '/layouts/sponsored_group_manage_sub_menu'
  end

  def new
     @group_links=GroupLink.new
     respond_to do |format|
     format.html { render(:template=> 'group_links/new_link_details', :layout => '/layouts/sponsored_group_manage_sub_menu') }
  end
 end

  def create
    @group_link=GroupLink.new(params[:group_link])
    @group_link.group_id=params[:group_id]
    if @group_link.save
       flash[:notice] = "A new booth link was created!"
     else
       flash[:errors] = @group_link.errors
    end
    redirect_to group_group_links_path(@group)
  end


   def destroy
    @group_link=GroupLink.new(params[:group_link])
    @group_link.destroy
    flash[:notice]="Group link was deleted"
  end

  def find_group
      @group = Group.find(params[:group_id])
  end
end
