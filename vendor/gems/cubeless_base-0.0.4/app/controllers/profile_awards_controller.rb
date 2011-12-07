class ProfileAwardsController < ApplicationController
  
  allow_access_for [:create, :destroy, :auto_complete_for_profile_awards] => :awards_admin

  def create
    award = Award.find(params[:profile_award][:award_id])
    profile = Profile.find_by_id(params[:profile_award][:id])
    profile_award = ProfileAward.new(:profile => profile, 
                                     :award => award, 
                                     :awarded_by => params[:profile_award][:awarded_by])
    profile_award.karma_points = params[:profile_award][:karma_points]
       
    respond_to do |format|
      format.json {
        if profile_award.save
          add_to_notices ("You've successfully awarded #{award.title} to #{profile.screen_name}")
          render :text => profile_award.to_json
        else
          add_to_errors(profile_award)
          render :text => { :errors => flash[:errors] }.to_json
          flash[:errors] = nil
        end
      }
    end
  end
  
  def destroy
    profile_award = ProfileAward.find_by_id(params[:id])
    award = profile_award.award
    
    if profile_award.destroy
      render :update do |page|
        page.replace "award_#{award.id}", render_award(award)
        page.select("#award_#{award.id} .recipients").first.show
        page["award_#{award.id}"].highlight
      end
    end
  end
  
  def make_default
    current_profile.profile_awards.find_by_id(params[:id]).make_default!
    respond_to do |format|
      format.html { redirect_to :back }
    end
  end
  
  def toggle_visibility
    profile_award = current_profile.profile_awards.find_by_id(params[:id])
    profile_award.toggle_visibility!
    profile_award.remove_default if (profile_award.is_default && !profile_award.visible)
    respond_to do |format|
      format.html { redirect_to :back }
    end
  end
  
  def auto_complete_for_profile_awards
    profiles = Profile.active.limit(20).find_by_full_name(params[:q]).sort{ |x,y|  x.full_name <=> y.full_name }
    render :partial => 'shared/name_suggestions', :locals => {:suggestions => profiles}
  end
end