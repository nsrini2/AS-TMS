class PublicContentController < ApplicationController
  
  layout "public"
  
  skip_before_filter :require_auth
  #skip_before_filter :require_terms_acceptance
  
  def refer_a_friend
    
  end
  
end