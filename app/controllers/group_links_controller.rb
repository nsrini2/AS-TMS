class GroupLinksController < ApplicationController
 allow_access_for :all => :sponsor_admin
 allow_access_for :all => :shady_admin

 before_filter :find_group_booth_links

 def new
     @group_link=GroupLink.new
     respond_to do |format|
      format.html { render(:partial => 'group_links/new', :layout => '/layouts/popup') }
    end
  end

  def create
    @group_link=GroupLink.new(params[:group_link])
    @group_link.group_id=params[:group_id]
    if @group_link.save
       flash[:notice] = "A new booth link was created!"
       redirect_to group_group_links_path(@group)
     else
       flash[:errors] = @group_link.errors
       render :action => "new"
    end
  end


   def destroy
    @group_link=GroupLink.find(params[:id])
    @group_link.destroy
    respond_to do |format|
      format.html { redirect_to :back }
    end
  end

  def find_group_booth_links
     @group = Group.find(params[:group_id])
     @booth_links = @group.group_links.all
  end
end
