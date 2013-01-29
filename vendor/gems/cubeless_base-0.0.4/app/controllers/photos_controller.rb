class PhotosController < ApplicationController

  before_filter :init_profile
  before_filter :init_photo, :except => [:new, :create]
  before_filter :profile_photo_protection, :except => [:select]

  def new
    respond_to do |format|
      format.js { render :partial => "upload_popup", :layout => "/layouts/popup" }
    end
  end

  def create
    existing = @profile.profile_photos.size
    if (existing < 5) && (@profile.karma.nth_photo_allowed?(existing+1))
      @photo = ProfilePhoto.new(params[:asset])
      if(@profile.profile_photos << @photo)
        @profile.update_attributes(:primary_photo => @photo) unless @profile.primary_photo
        @selected_photo = @photo
      end
    end
    respond_to do |format|
      format.html {
         add_to_errors @photo
         if flash[:errors].blank?
           return redirect_to profile_path(@profile)
         else
           return redirect_to profile_path(@profile)
           flash[:errors] = nil
         end
      }
    end
  end

  def edit
    respond_to do |format|
      format.js { render :partial => "upload_popup", :layout => "/layouts/popup", :locals => { :photo => @photo } }
    end
  end

  def update  
    @selected_photo = @photo if @photo.update_attributes(params[:asset])
    respond_to do |format|
      format.html {
         add_to_errors @photo
         if flash[:errors].blank?
           return redirect_to profile_path(@profile)
         else
           return redirect_to profile_path(@profile)
           flash[:errors] = nil
         end
      }
    end
  end

  def destroy
    @photo.destroy if @photo
    respond_to do |format|
      format.json {
        render :text => @photo.to_json
      }
      format.html { redirect_to :back }
    end
  end

  def make_primary
    @selected_photo = @profile.primary_photo = @photo
    @profile.save
    respond_to do |format|
      format.js { render :partial => "profiles/photos", :layout => false }
    end
  end

  def select
    @selected_photo = @photo
    respond_to do |format|
      format.js { render :partial => "profiles/photos", :layout => false }
    end
  end

  private

  def profile_photo_protection
    raise unless is_editable?(@profile)
  end

  def init_profile
    @profile = Profile.find(params[:profile_id])
  end

  def init_photo
    @photo = ProfilePhoto.find_by_id(params[:id])
  end

  def refresh_parent
    responds_to_parent do
      refresh_profile_photos
    end
  end

  def refresh_profile_photos
    @profile.reload
    render :update do |page|
      page.call 'cClick'
      replace_flash_error_for(page, @photo)
      page[:alternate_photos].replace_html render(:partial => 'profiles/photos') unless @photo && @photo.errors.size > 0
      page.select("#top_right div.photo_wrapper").first.replace primary_photo_for(@profile, { :hide_status_indicator => true }) if @profile == current_profile && (@photo == @profile.primary_photo || @profile.primary_photo == nil)
    end
  end

end