require File.dirname(__FILE__) + '/../spec_helper'

describe GroupOwned do
  
  class Something
    include GroupOwned
  end
  
  before(:each) do
    @something = Something.new
  end
  
  describe "get group recipients" do
    before(:each) do
      @something.stub!(:authored_by?).and_return(false)
      
      @member = mock_model(User, :email => "test@test.com")
      @membership = mock_model(GroupMembership, :wants_notification_for? => true, :member => @member)
      @memberships = [@membership]
    end
        
    it "should not get the email of a member who does not want notifications" do
      @membership.stub!(:wants_notification_for?).and_return(false)
      
      @something.get_group_recipients(@memberships).should == []
    end
    it "should not get the email of the author" do
      @something.stub!(:authored_by? => true)
      @something.get_group_recipients(@memberships).should == []      
    end
    it "should get the email of a member" do      
      @something.get_group_recipients(@memberships).should == ["test@test.com"]
    end
  end
  
end