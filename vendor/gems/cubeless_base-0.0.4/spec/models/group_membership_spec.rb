require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe GroupMembership do
  
  before(:each) do
    @group = mock_model(Group, :is_member? => false, :is_public? => true, :owner_id => 1)
    @profile = mock_model(Profile, 
      :num_group_slots_remaining => 5,
      :has_global_group_email_preferences? => true,
      :group_note_email_status => 1,
      :group_blog_post_email_status => 1,
      :group_post_email_status => 1,
      :group_referral_email_status => 1)
    @membership = GroupMembership.new
    @valid_attributes = {
      :group => @group,
      :member => @profile
    }
    ActivityStreamEvent.stub!(:last).and_return(ActivityStreamEvent.new)
  end
  
  it "should create a new instance given valid attributes" do
    @membership.attributes = @valid_attributes
    @membership.should be_valid
  end
  
  it "should belong to a Profile (member)" do
    @membership.attributes = @valid_attributes.except(:member)
    @membership.should have(1).error_on(:member)
  end
  
  it "should belong to a Group" do
    @membership.attributes = @valid_attributes.except(:group)
    @membership.should have(1).error_on(:group)
  end
  
  it "should be unique" do
    @membership.attributes = @valid_attributes
    @group.stub!(:is_member? => true)
    @membership.should have(1).error_on(:base)
  end
  
  it "should require an invitation for an invite only Group (has invitation)" do
    @membership.attributes = @valid_attributes
    @group.stub!(:is_public?).and_return(false)
    @group.stub!(:has_members?).and_return(true)
    @profile.stub!(:has_received_invitation?, :group => @group).and_return(true)
    @membership.should be_valid
  end
  
  it "should require an invitation for an invite only Group (does not have invitation)" do
    @membership.attributes = @valid_attributes
    @group.stub!(:is_public?).and_return(false)
    @group.stub!(:has_members?).and_return(true)
    @profile.stub!(:has_received_invitation?, :group => @group).and_return(false)
    @membership.should have(1).error_on(:base)
  end
  
  it "should require an open group slot on the Profile (member)" do
    @membership.attributes = @valid_attributes
    @profile.stub!(:num_group_slots_remaining).and_return(0)
    @membership.should have(1).error_on(:base)
  end
  
  it "should destroy the invitation once joined" do
    @sender = mock_model(Profile)
    @receiver = @profile
    @profile.stub!(:has_received_invitation? => false)
    @profile.stub!(:is_sponsored? => false)
    @profile.stub!(:group_invitation_email_status => false)
    @invitation = GroupInvitation.create(:group => @group, :sender => @sender, :receiver => @receiver)
    @membership.update_attributes({ :group => @group, :member => @receiver })
    GroupInvitation.should have(0).records
  end

  describe "Email Preferences" do
    before(:each) do
      @membership.update_attributes(@valid_attributes)
      @membership.email_preferences.note = false
      @membership.email_preferences.blog_post = false
      @membership.email_preferences.group_talk_post = false
      @membership.email_preferences.question_referral = false
    end
    
    describe "with Global Preferences on" do
      before(:each) do
        @profile.stub!(:has_global_group_email_preferences? => true)
      end
      
      [Note.new, BlogPost.new, GroupPost.new, QuestionReferral.new].each do |item|
        it "should use global #{item.class.name} settings" do
        @membership.wants_notification_for?(item).should be_true
        end
      end

    end
    
    describe "with Global Preferences off" do
      before(:each) do
        @profile.stub!(:has_global_group_email_preferences? => false)
      end
      
      [Note.new, BlogPost.new, GroupPost.new, QuestionReferral.new].each do |item|
        it "should use #{item.class.name} settings per Group" do
        @membership.wants_notification_for?(item).should be_false
        end
      end
    end
    
  end
end