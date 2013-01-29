class VotesController < ApplicationController
  before_filter :set_owner

  def helpful
    create(true)
  end

  def not_helpful
    create(false)
  end

private

  def set_owner
    raise(ArgumentError, "Votes must receive owner_type and owner_id params") unless params && params[:owner_type] && params[:owner_id]
    model = Rails::Application.const_get(params[:owner_type].camelize)
    @owner = model.find(params[:owner_id])
  end

  def create(vote_value)
    unless @owner.authored_by?(current_profile)
      vote = Vote.find_or_initialize_by_profile_id_and_owner_id_and_owner_type(current_profile.id,@owner.id,@owner.class.to_s)
      vote.vote_value = vote_value
      vote.save
      # pull new aggregate counts
      @owner.reload
    end
    
    respond_to do |format|
      format.js { render :partial => '/votes/stats', :locals => { :owner => @owner } }
      format.html { render :partial => '/votes/stats', :locals => { :owner => @owner } }
    end
  end

end
