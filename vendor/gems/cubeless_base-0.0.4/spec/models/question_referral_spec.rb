require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe QuestionReferral do
  before(:each) do
    @referral = QuestionReferral.new
    @referer = mock_model(Profile)
    @receiver = mock_model(Profile)
    @question = mock_model(Question)
    @valid_attributes = {
      :question => @question,
      :referer => @referer,
      :owner => @receiver
    }
  end
  
  it "should only be authored by the creator (referer)" do
    @referral.attributes = @valid_attributes
    @referral.should be_authored_by(@referer)
    @referral.should_not be_authored_by(@receiver)
  end
  
  describe "send group blog post" do
    before(:each) do
      @group = mock_model(Group)
      @referral.stub!(:owner).and_return(@group)
      
      @memberships = []
      @group.stub!(:group_memberships).and_return(@memberships)
    end
    after(:each) do
      @referral.send_group_question_referral
    end
    it "should deliver the email via batch mail" do
      @member = mock_model(User, :email => "test@test.com")
      @memberships << mock_model(GroupMembership, :wants_notification_for? => true, :member => @member)
      BatchMailer.should_receive(:mail).with(@referral, ["test@test.com"])
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