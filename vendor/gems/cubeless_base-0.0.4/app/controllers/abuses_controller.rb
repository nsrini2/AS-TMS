class AbusesController < ApplicationController

  allow_access_for :destroy => :shady_admin

  before_filter :get_abuseable_from_parent, :except => [:destroy]

  def new
    @abuse = Abuse.new
    @abuse.abuseable = @abuseable
    #  SSJ the polymorphic_url is buggy when passing symbols in 3.0.10
    @form_path = view_context.polymorphic_path(@abuse.abuseable) + "/abuse"
    
    respond_to do |format|
      format.js { render(:partial => 'abuse_popup', :layout => '/layouts/popup') }
      # format.js { render(:text => @abuseable.inspect ) }
    end
  end

  def create
    abuse = Abuse.new(params[:abuse])
    abuse.profile_id = current_profile.id
    abuse.abuseable = @abuseable
    if @abuseable.is_a?(Profile)
      abuse.owner_id = @abuseable.id
    elsif @abuseable.is_a?(GalleryPhoto)
      abuse.owner_id = @abuseable.uploader_id
    elsif @abuseable.is_a?(Group)
      abuse.owner_id = @abuseable.owner_id
    else
      abuse.owner_id = @abuseable.profile_id
    end
    respond_to do |format|
      format.html {  }
      format.json {
        if abuse.save
          render(:text => abuse.to_json)
        else
          add_to_errors(abuse)
          render(:text => { :errors => flash[:errors] }.to_json)
          flash[:errors] = nil
        end
      }
    end
  end

  def destroy
    Abuse.find(params[:id]).mark_removed(current_profile.id).save!
    redirect_to shady_admin_admin_path
  end

  private

  def get_abuseable_from_parent
    if params[:group_post_id]
      @abuseable = GroupPost.find(params[:group_post_id])
    else
      @abuseable = parent
    end
  end

end
