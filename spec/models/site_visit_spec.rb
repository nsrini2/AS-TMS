require 'spec_helper'

describe SiteVisit do
  before(:each) do
    @profile = Factory.build(:profile);
    @profile.stub!(:id).and_return(2)
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
  
  it "should calculate the number of visitors by range" do
    t = Date.today
    # ceate a visit for today
    SiteVisit.track(@profile)
    start_date = t-1
    end_date = t + 1
    count_by_range = SiteVisit.visitors_by_range(start_date, end_date)
    
    assert_equal count_by_range, 1, "Visitors by range did not find entry, found " + count_by_range.to_s
    assert_equal SiteVisit.select("DISTINCT profile_id").where("created_at between ? AND ? ", start_date, end_date).count, count_by_range, "visitors_by_range did not return the expected result"
  
    count_by_range = SiteVisit.visitors_by_range(start_date-2, start_date)
    assert_not_equal SiteVisit.select("DISTINCT profile_id").where("created_at between ? AND ? ", start_date, end_date).count, count_by_range, "visitors_by_range did not return the expected result"
  end
end
