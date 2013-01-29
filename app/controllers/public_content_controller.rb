class PublicContentController < ApplicationController
  
  layout "public"
  
  skip_before_filter :require_auth
  
  def refer_a_friend
    
  end
  
end