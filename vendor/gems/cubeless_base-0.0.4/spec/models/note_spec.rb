require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Note do
  before(:each) do
    @note = Note.new
    @sender = mock_model(Profile)
    @receiver = mock_model(Profile)
    @valid_attributes = {
      :sender => @sender,
      :receiver => @receiver
    }
  end
  
  it "should only be authored by the creator (sender)" do
    @note.attributes = @valid_attributes
    @note.should be_authored_by(@sender)
    @note.should_not be_authored_by(@receiver)
  end
  
  describe "send group note" do
    before(:each) do
      @group = mock_model(Group)
      @note.stub!(:receiver).and_return(@group)
      
      @memberships = []
      @group.stub!(:group_memberships).and_return(@memberships)
    end
    after(:each) do
      @note.send_group_note
    end
    it "should deliver the email via batch mail" do
      @member = mock_model(User, :email => "test@test.com")
      @memberships << mock_model(GroupMembership, :wants_notification_for? => true, :member => @member)
      BatchMailer.should_receive(:mail).with(@note, ["test@test.com"])
    end
    it "should not deliver email to a member who does not want notifications" do
      @membership = mock_model(GroupMembership, :wants_notification_for? => false)
      BatchMailer.should_not_receive(:mail)        
    end
    it "should not deliver email to the author" do
      @note.stub!(:authored_by? => true)
      BatchMailer.should_not_receive(:mail)
    end
  end
end