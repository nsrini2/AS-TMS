class GroupPhotosController < ApplicationController

  before_filter :init_group
  before_filter :group_photo_protection

  def create
    @group.update_attributes(:last_updated_by => current_profile.id)
    if (@group.group_photo = GroupPhoto.new(params[:asset]))
      @group.update_attributes(:primary_photo => @group.group_photo)
    end
    refresh_parent
  end

  def update
    @group.update_attributes(:last_updated_by => current_profile.id)
    @group.group_photo.update_attributes(params[:asset])
    refresh_parent
  end

  def destroy
    @group.group_photo.destroy
    refresh_group_user_card
  end

  private

  def refresh_parent
    responds_to_parent do
      refresh_group_user_card
    end
  end

  def refresh_group_user_card
    cached_photo = @group.group_photo
    @group.reload
    render :update do |page|
      page.call 'cClick'
      replace_flash_error_for(page, cached_photo)
      page[:group_user_card].replace_html :partial => 'groups/group_user_card'
    end
  end

  private
  def init_group
    @group = Group.find(params[:group_id])
  end
  
  def group_photo_protection
    is_editable?(@group)
  end

end