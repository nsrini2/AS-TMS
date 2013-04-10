class GroupAnnouncementsController < ApplicationController
  before_filter :init_group_announcement

  def show
    render :template => 'group_announcements/_group_announcement_form', :layout => 'layouts/group_manage_sub_menu'
  end

  def update
    if params[:commit] == 'Remove'
      params[:group_announcement][:content] = ''
      params[:group_announcement][:start_date] = ''
      params[:group_announcement][:end_date] = ''
    end
    @group_announcement.update_attributes!(params[:group_announcement])
    redirect_to group_announcement_path
  end

  protected
  def init_group_announcement
    @group = Group.find(params[:group_id])
    redirect_to group_path(@group) and return unless is_editable?(@group)
    @group_announcement = @group.group_announcement || GroupAnnouncement.create!(:group => @group)
  end
end