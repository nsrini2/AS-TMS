class StatusesController < ApplicationController
  
  deny_access_for :all => :sponsor_member
  
  def index
    setup_profile
    
    @statuses = if @profile
                  @content_for_status_tab = "selected"
                  Status.by_profile(@profile).find(:all, :page => default_paging)
                else
                  Status.find(:all, :order => "created_at DESC", :page => default_paging)
                end
    
    if @profile
      render :layout => "_my_stuff"
    else
      render
    end
  end
  
  def create
    @profile = current_profile
    @status = Status.new(:body => params[:status][:body], :profile_id => current_profile.id)
    if @status.save
      if params[:profile_status]
        render :partial => "profile_status", :locals => { :status => @status }
      else
        render :partial => "widget_status", :locals => { :status => @status }
      end
    else
      render :text => "Not Saved"
    end
  end
  
  def destroy
    setup_profile
    
    return unless @profile && @profile == current_profile
    
    @status = Status.find(params[:id])
    @status.destroy
    
    redirect_to profile_statuses_path(@profile)
  end
  
  private
  def setup_profile
    @profile = Profile.find(params[:profile_id]) if params[:profile_id]
  end
  
end