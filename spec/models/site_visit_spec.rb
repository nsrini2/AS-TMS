require 'spec_helper'

describe SiteVisit do
  before(:each) do
    @profile = Factory.build(:profile);
  end
  
  it "should create one entry each time a user visits the site on a given day" do
    visits = SiteVisit.count
    # track fisrt visit of day
    SiteVisit.track(@profile)
    assert_equal SiteVisit.count,  visits + 1, "The new users activity was not added to site_visits"
    
    # second visit of day should not increase count
    SiteVisit.track(@profile)
    assert_equal SiteVisit.count,  visits + 1, "The users activity was added multiple times to site_visits"
    
  end
end
