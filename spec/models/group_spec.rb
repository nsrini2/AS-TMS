require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Group do

  before(:each) do
    @group = Group.new
    @valid_attributes = { 
      :name => 'Test Group',
      :description => 'Test Group description',
      :tags => 'test'
    }
  end
  
  it "should create a new instance given valid attributes" do
    @group.attributes = @valid_attributes
    @group.should be_valid
  end
it "should belong to a SponsorAccount" do
    @group.attributes = @valid_attributes.except(:sponsor_account)
    @group.should have(0).error_on(:sponsor_account)
  end

  describe "send mass mail" do
    before(:each) do
      @sender = mock_model(Profile, :email => "test@test.com")
      @member = mock_model(Profile, :email => "test1@test.com")
      
      Profile.stub!(:find).with(@sender.id).and_return(@sender)
      
      BatchMailer.stub!(:delay).and_return(BatchMailer)
      BatchMailer.stub!(:group_mass_mail).and_return("email")
    end
    
    def send_mass_mail(test_enabled=false)
      @group.send_mass_mail(@sender.id, "Test", "This is a test.", :test_enabled => test_enabled)
    end
    
    it "should lookup the sender" do
      Profile.should_receive(:find).with(@sender.id).and_return(@sender)
      
      send_mass_mail
    end
    
    it "should not delay the BatchMailer" do
      BatchMailer.should_not_receive(:delay).and_return(BatchMailer)      
      send_mass_mail
    end
    
    describe "recipients" do
      it "should be just the sender if it's a test message" do
        BatchMailer.should_receive(:group_mass_mail).with(@group, @sender, "Test", "This is a test.", [@sender.email])
        
        send_mass_mail(true)
      end
      it "should be everyone in the group if it's not a test message" do
        @group.should_receive(:members).and_return([@sender, @member])
        BatchMailer.should_receive(:group_mass_mail).with(@group, @sender, "Test", "This is a test.", [@sender.email, @member.email])
        
        send_mass_mail
      end
    end

  end
end
