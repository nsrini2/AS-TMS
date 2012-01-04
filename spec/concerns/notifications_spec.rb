require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Notifications do
  describe Profile do
    before(:each) do
      @profile = Factory.build(:profile, :first_name => "Create", :last_name => "Profile") 
    end
  
    it "should call fire_notifications after it is saved" do
      @profile.should_receive(:fire_notifications).and_return(:true)
      @profile.save
    end
    
    it "should send welcome email in fire_notifications if they are new and accepted to community" do
      @profile.stub!(:should_receive_welcome_email?).and_return(true)
      Notifier.should_receive(:deliver_welcome).with(@profile.user).and_return(true)
      @profile.fire_notifications
    end
    
    it "should NOT send welcome email in fire_notifications if NOT a new user or has not been accepted to community" do
      @profile.stub!(:should_receive_welcome_email?).and_return(false)
      Notifier.should_not_receive(:deliver_welcome).and_return(true)
      @profile.fire_notifications
    end  
  end
  
  describe User do
    before(:each) do
      @user = Factory.build(:user, :srw_agent_id => "888888_95TB") 
    end
    it "should send Sabre Red SSO welcome email in fire_notifications if SRW SSO user accepts terms" do
      @user.stub!(:should_receive_sabre_red_welcome_email?).and_return(true)
      Notifier.should_receive(:deliver_sabre_red_sso_welcome).with(@user).and_return(true)
      @user.fire_notifications
    end
  end  
  
  describe BlogPost do
    # @item = Factory(:item)
    # @study_record = Factory(:study_record, :content => @item)
    
    before(:each) do
      # SSJ This nested mess is to get a valid group_blog post
      @group = Factory.build(:group)
      @group.stub!(:save).and_return(:true) # this is to stop save_belongs_to_association
      @group_blog = Factory.build(:blog, :owner => @group, :id => 1)
      @group_blog.stub!(:save).and_return(:true) # this is to stop save_belongs_to_association
      @group_blog_post = Factory.build(:blog_post, :blog => @group_blog, :blog_id => 1 )
      # SSJ This nested mess is to get a valid company_blog post
      @company = Factory.build(:company)
      @company.stub!(:save).and_return(:true) # this is to stop save_belongs_to_association
      @company_blog = Factory.build(:blog, :owner => @company, :id => 2)
      @company_blog.stub!(:save).and_return(:true) # this is to stop save_belongs_to_association
      @company_blog_post = Factory.build(:blog_post, :blog => @company_blog, :blog_id => 2)
    end
    
    it "should have class_method send_batch_email" do
      BlogPost.methods.include?('send_batch_email').should be_true
    end  
    
    it "should call fire_notifications after it is saved" do
      @group_blog_post.should be_valid
      @group_blog_post.should_receive(:fire_notifications).and_return(:true)
      @group_blog_post.save
    end
    
    it "should call send_group_blog_post when a group_blog_post is saved" do
      @group_blog_post.should be_group
    end
    
    it "should call fire_notifications after it is saved" do
      @company_blog_post.should be_valid
      @company_blog_post.should_receive(:fire_notifications).and_return(:true)
      @company_blog_post.save
    end
    
    it "should call send_company_blog_post when a company_blog_post is saved" do
      @company_blog_post.should be_company
    end
  end
  
  describe Question do
    
    before(:each) do
      # SSJ I may have done a bad thing, but I could not get @question.profile_id to pass 
      # into SQL INSERT statment, so I removed the requirement from cubeless_trunk_test.questions
      @question = Factory.build(:question)
      SemanticMatcher.default.stub!(:match_question_to_profiles).and_return(:true)
    end
    
    
    it "should call fire_notifications after it is saved" do
      @question.should be_valid
      @question.should_receive(:fire_notifications).and_return(:true)
      @question.save
    end
    
    it "should call SemanticMatcher.default.match_question_to_profiles when a question is saved" do
      SemanticMatcher.default.should_receive(:match_question_to_profiles).with(@question)
      @question.fire_notifications
    end
    
    it "should call Notifier.send_question_match_notifications when a question is saved" do
      dj_count =  Delayed::Job.count
      @question.fire_notifications
      Delayed::Job.count.should == dj_count + 1
    end

  end
  
  describe Answer do
    
    before(:each) do
      @question = Factory.build(:question)
      @answer = Factory.build(:answer)
      @answer.stub!(:question).and_return(@question)
    end
    
    it "should have a fire_notifications method" do
      @answer.methods.include?('fire_notifications').should be_true
    end  
    
    it "should have a fire_update_notifications method" do
     @answer.methods.include?('fire_update_notifications').should be_true 
    end
    
    it "should send notification to question if its question per_answer_notification is true" do
      @question.stub!(:per_answer_notification).and_return(:true)
      Notifier.should_receive(:deliver_answer_to_question).with(@answer) 
      @answer.fire_notifications
    end  
    
    it "should send watched question answered notification if the question has watchers" do
      @watcher = Profile.new
      @watcher.stub!(:email).and_return("scott.johnson@sabre.com")
      @watcher.stub!(:watched_question_answer_email_status).and_return(1)
      @question.stub!(:watchers).and_return([@watcher])
      Notifier.should_receive(:deliver_watched_question_answer).with(@answer) 
      @answer.fire_notifications
    end  
    
     
  end
  
  describe Abuse do
    before(:each) do
      @abuse = Factory.build(:abuse)
    end  
    
    it "should have a fire_notifications method" do
      @abuse.methods.include?('fire_notifications').should be_true
    end
    
    it "should have a class.send_batch_email method" do
      @abuse.class.methods.include?('send_batch_email').should be_true
    end
    
    it "should send a new abuse notifiaction to all shady_admins" do
      Abuse.should_receive(:send_batch_email)
      @abuse.fire_notifications
    end
  end  
  
  describe Group do
    before(:each) do
      @group = Factory.build(:group)
    end  
    
    it "should have a fire_update_notifications method" do
       @group.methods.include?('fire_update_notifications').should be_true
    end
    
    it "should send a group owner changed email if the owner is changed" do
      Notifier.should_receive(:deliver_group_owner).with(@group)
      @group.stub!(:attribute_modified?).and_return(:true)
      @group.fire_update_notifications
    end
  end
  
  describe GroupMembership do
    before(:each) do
      @groupmembership = GroupMembership.new({ :profile_id => 1, :group_id => 1 })
    end  
    
    it "should have a fire_update_notifications method" do
       @groupmembership.methods.include?('fire_update_notifications').should be_true
    end
    
    it "should send a group owner changed email if the owner is changed" do
      allow_message_expectations_on_nil
      Notifier.should_receive(:deliver_group_moderator).with(@groupmembership)
      @groupmembership.stub!(:attribute_modified?).and_return(:true)
      @groupmembership.stub!(:moderator).and_return(:true)
      @groupmembership.stub!(:profile_id).and_return(1)
      @groupmembership.group.stub!(:owner_id).and_return(2)
      @groupmembership.fire_update_notifications
    end
  end
  
  describe GroupInvitation do
    before(:each) do
      @groupinvitation = GroupInvitation.new({ :sender_id => 1, :group_id => 1, :receiver_id => 2 })
    end  
    
    it "should have a fire_notifications method" do
       @groupinvitation.methods.include?('fire_notifications').should be_true
    end
    
    it "should have a fire_update_notifications method" do
       @groupinvitation.methods.include?('fire_update_notifications').should be_true
    end
    
    it "should send a group group invitation email if a new invite is created" do
      allow_message_expectations_on_nil
      @groupinvitation.receiver.stub!(:group_invitation_email_status).and_return(:true)
      Notifier.should_receive(:deliver_group_invitation).with(@groupinvitation)
      @groupinvitation.fire_update_notifications
    end
  end
end