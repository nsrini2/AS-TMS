class SystemAnnouncementsController < ApplicationController

  allow_access_for :all => :content_admin

  def create
    if params[:commit] == 'Remove'
      params[:object][:content] = ''
      params[:object][:start_date] = ''
      params[:object][:end_date] = ''
    end
    SystemAnnouncement.update params[:object]
    add_to_notices "System Announcement has been updated!"
    redirect_to system_announcement_admin_path
  end

end