require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe ProfileAward do
  before(:each) do
    @valid_attributes = {        
      :profile => Profile.new, 
      :awarded_by => "2",
      :karma_points => 98
    }
    
    @profile_award = ProfileAward.new(@valid_attributes)
  end
  
  it "should be valid" do
    puts @profile_award.valid?
    puts @profile_award.errors.full_messages
    @profile_award.should be_valid
    
  end  
  
  describe "validations" do
    it "should not accept negative karma points" do
      @profile_award.karma_points = -9
      @profile_award.should_not be_valid
    end
  end
  
  describe "karma points" do
    it "should convert non-numerics strings to 0" do
      @profile_award.karma_points = "s-r45"
      @profile_award.karma_points.should == 0   
    end
    it "should convert numeric strings to integers" do
      @profile_award.karma_points = "41"
      @profile_award.karma_points.should == 41  
    end
  end
  
end

