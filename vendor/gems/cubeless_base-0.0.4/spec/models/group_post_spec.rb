require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe GroupPost do
  before(:each) do
    @group_post = GroupPost.new
    @profile = mock_model(Profile)
    @group = mock_model(Group)
    @valid_attributes = {
      :post => "My post",
      :group => @group,
      :profile => @profile
    }
  end

  it "should create a new instance given valid attributes" do
    @group_post.attributes = @valid_attributes
    @group_post.should be_valid
  end
  
  it "should be invalid without a post" do
    @group_post.attributes = @valid_attributes.except(:post)
    @group_post.should have(1).error_on(:post)
  end
  
  it "should be invalid with a post longer than 256 characters" do
    @group_post.attributes = @valid_attributes
    @group_post.post = 'c'*257
    @group_post.should have(1).error_on(:post)
  end
  
  it "should belong to a Group" do
    @group_post.attributes = @valid_attributes.except(:group)
    @group_post.should have(1).error_on(:group)
  end
  
  it "should belong to a Profile" do
    @group_post.attributes = @valid_attributes.except(:profile)
    @group_post.should have(1).error_on(:profile)
  end
  
  it "should only be authored by the creator" do
    @group_post.attributes = @valid_attributes
    @group_post.should be_authored_by(@profile)
    @group_post.should_not be_authored_by( mock_model(Profile) )
  end
  
  describe "send group post" do
    before(:each) do
      @group = mock_model(Group)
      @group_post.stub!(:group).and_return(@group)
      
      @memberships = []
      @group.stub!(:group_memberships).and_return(@memberships)
    end
    after(:each) do
      @group_post.send_group_post
    end
    it "should deliver the email via batch mail" do
      @member = mock_model(User, :email => "test@test.com")
      @memberships << mock_model(GroupMembership, :wants_notification_for? => true, :member => @member)
      BatchMailer.should_receive(:mail).with(@group_post, ["test@test.com"])
    end
    it "should not deliver email to a member who does not want notifications" do
      @membership = mock_model(GroupMembership, :wants_notification_for? => false)
      BatchMailer.should_not_receive(:mail)        
    end
    it "should not deliver email to the author" do
      @blog_post.stub!(:authored_by? => true)
      BatchMailer.should_not_receive(:mail)
    end
  end
end