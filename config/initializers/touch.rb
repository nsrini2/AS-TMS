# SSJ 11-08-2012 for some crazy reason Time.now is not creating a valid MySQL time stamp, 
# so the updated_at attribute was not getting set with touch
# it may be due to the mysql gem we are using. I tried switching to mysql2, but got nasty errors, so we get this

class ActiveRecord::Base
  alias_method :_org_touch, :touch
  
  def touch!
    update_attribute("updated_at", "'#{DateTime.now}'")
  end
  
  alias_method :touch, :touch!
end