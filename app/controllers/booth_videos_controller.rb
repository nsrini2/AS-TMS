class BoothVideosController < ApplicationController

  def new
    @booth_video = BoothVideo.new
    #render :layout => 'sponsored_group_manage_sub_menu'
  end

  def create
    @booth_video = BoothVideo.new(params[:booth_video])
    if params[:marketing_video_file].blank?
       flash[:errors] = "We need a video file for creating this booth video"
       render :action => "new"
    else
       @booth_video.marketing_video=MarketingVideo.new(:uploaded_data => params[:marketing_video_file])
       Rails.logger.info("Niranjana Rahul - #{@booth_video.marketing_video.public_filename}")
       #@video.convert
       #flash[:notice] = 'Video has been uploaded'
       #redirect_to :action => 'show'
       #else
       #render :action => 'new'
    end
  end

  def show
    @video = BoothVideo.find(params[:id])
    render :template => 'booth_video/booth_video', :layout => 'sponsored_group_manage_sub_menu'
  end
  
  def delete
    @video = BoothVideo.find(params[:id])
    @video.destroy
    redirect_to :action => 'show'
  end
end

