class VotesController < ApplicationController

  def create(vote_value)
    owner_type, owner_id, model = 'Answer', params[:answer_id], Answer
    unless model.find(owner_id).authored_by?(current_profile)
      vote = Vote.find_or_initialize_by_profile_id_and_owner_id_and_owner_type(current_profile.id,owner_id,owner_type)
      vote.vote_value = vote_value
      vote.save
    end  
    @model = (model == Answer) ? model.where(:id => owner_id).includes(:profile => [:user, :primary_photo]).first : model.find(owner_id) # causes aggregates to be recalculated
    respond_to do |format|
      format.js { render :partial => '/votes/stats', :locals => { :model => @model } }
      format.html { render :partial => '/votes/stats', :locals => { :model => @model } }
    end
  end

  def helpful
    create(true)
  end

  def not_helpful
    create(false)
  end

end
