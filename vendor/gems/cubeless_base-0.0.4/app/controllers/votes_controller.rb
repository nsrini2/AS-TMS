class VotesController < ApplicationController

  def create(vote_value)
    owner_type, owner_id, model = 'Answer', params[:answer_id], Answer
    
    Vote.find_or_create_by_profile_id_and_owner_id_and_owner_type_and_vote_value(current_profile.id,owner_id,owner_type,vote_value) unless model.find(owner_id).authored_by?(current_profile)
    @model = (model == Answer) ? model.find_summary(owner_id) : model.find(owner_id) # causes aggregates to be recalculated
    respond_to do |format|
      format.js { render :partial => '/votes/stats', :locals => { :model => @model } }
    end
  end

  def helpful
    create(true)
    render :partial => '/votes/stats', :locals => { :model => @model }
  end

  def not_helpful
    create(false)
    render :partial => '/votes/stats', :locals => { :model => @model }
  end

end
