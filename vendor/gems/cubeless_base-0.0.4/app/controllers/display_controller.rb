class DisplayController < ApplicationController

  skip_before_filter :require_auth
  skip_before_filter :require_terms_acceptance
  deny_access_for :event_stream => :sponsor_member


  def event_stream
     render :partial => 'shared/event_stream', :layout => false
  end

  def ping
  end

  def our_story
  end

  def terms_and_conditions
  end
end