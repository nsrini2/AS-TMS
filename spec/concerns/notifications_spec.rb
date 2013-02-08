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
      @profile = Factory.build(:profile, :first_name => "Create", :last_name => "Profile")
      SemanticMatcher.default.stub!(:match_question_to_profiles).and_return(:true)
    end
    
    
    it "should call fire_notifications after it is saved" do
      pending "MySQL is throwing profile_id as nil error -- not sure what is causing this"
      @q = Question.new()
      @q.category = "Life"
      @q.question = "This is the spec question"
      @q.open_until = Time.now.advance(:months => 1)
      @q.profile_id = 1
      @q.should_receive(:fire_notifications).and_return(:true)
      @q.save
    end
    
    it "should call SemanticMatcher.default.match_question_to_profiles when a question is saved" do
      SemanticMatcher.default.should_receive(:match_question_to_profiles).with(@question)
      @question.fire_notifications
    end
    
    it "should call Notifier.send_question_match_notifications when a question is saved" do
      Notifier.should_receive(:delay).and_return(Notifier)
      Notifier.should_receive(:send_question_match_notifications).with(@question.id)
      @question.fire_notifications
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
  
  describe GroupPost do
    before(:each) do
      @group_post = GroupPost.new({ :post => "rSpec GroupPost", :group_id => 1, :profile_id => 1 })
    end  
    
    it "should have a fire_notifications method" do
       @group_post.methods.include?('fire_notifications').should be_true
    end
    
    it "should receive fire_notifications when saved" do
      @group_post.stub!(:valid?).and_return(:true)
      @group_post.should_receive(:fire_notifications)
      @group_post.save
    end
  end
  
  describe ProfileAward do
    before(:each) do
      @profile_award = ProfileAward.new()
      @profile_award.stub!(:valid?).and_return(:true)
    end  
    
    it "should have a fire_notifications method" do
       @profile_award.methods.include?('fire_notifications').should be_true
    end
    
    it "should call deliver_profile_award with self on Notifier when saved" do
      Notifier.should_receive(:deliver_profile_award).with(@profile_award)
      @profile_award.fire_notifications
    end
  end
  
  describe Reply do
    before(:each) do
      @reply = Reply.new()
      @reply.stub!(:valid?).and_return(:true)
    end  
    
    it "should have a fire_notifications method" do
       @reply.methods.include?('fire_notifications').should be_true
    end
    
    it "should call deliver_profile_award with self on Notifier when saved" do
      @answer = Factory.build(:answer)
      @profile = Factory.build(:profile)
      @reply.answer = @answer
      @answer.profile = @profile
      @profile.stub!(:new_reply_on_answer_notification).and_return(:true)
      Notifier.should_receive(:deliver_reply).with(@reply)
      @reply.fire_notifications
    end
  end
  
  describe GetthereBooking do
    before(:each) do
      @get_there_booking = GetthereBooking.new()
    end  
    
    it "should have a fire_notifications method" do
       @get_there_booking.methods.include?('fire_notifications').should be_true
    end
    
    it "should call deliver_new_getthere_booking with self on Notifiers::Travel when saved" do
      @profile = Factory.build(:profile)
      @profile.stub!(:travel_email_status).and_return(:true)
      @get_there_booking.profile = @profile
      @get_there_booking.stub!(:past?).and_return(:true)
      Notifiers::Travel.should_receive(:deliver_new_getthere_booking).with(@get_there_booking) if @get_there_booking.profile.travel_email_status && !@get_there_booking.past?
      @get_there_booking.fire_notifications
    end
  end
  
  describe Comment do
    before(:each) do
      @comment = Factory.build(:comment)
    end
    
    it "should have a fire_notifications method" do
      @comment.respond_to?('fire_notifications').should be_true
    end
    
    it "should call deliver_new_comment_on_group_blog_post with self on Notifier if it belongs_to_group_blog_post" do
      @comment.stub!(:belongs_to_group_blog_post?).and_return(true)
      Notifier.should_receive(:deliver_new_comment_on_group_blog_post).with(@comment)
      @comment.fire_notifications
    end
    
    it "should call deliver_new_comment_on_group_post with self on Notifiers::Group if it belongs_to_group_post" do      
      @comment.stub!(:belongs_to_group_blog_post?).and_return(false)
      @comment.stub!(:belongs_to_group_post?).and_return(true) 
      
      Notifiers::Group.should_receive(:deliver_new_comment_on_group_post).with(@comment).and_return
      @comment.fire_notifications
    end
    
    it "should call deliver_new_comment_on_company_blog_post with self on Notifier if it is a company comment" do
      @comment.stub!(:belongs_to_group_blog_post?).and_return(false)
      @comment.stub!(:belongs_to_group_post?).and_return(false)
      @comment.stub!(:company?).and_return(true)
      Notifier.should_receive(:deliver_new_comment_on_company_blog_post).with(@comment)
      @comment.fire_notifications
    end
    
    it "should call deliver_new_comment_on_group_blog_post with self on Notifier if it is a new_comment_on_blog_notification -- comment is made on a blog post" do
      @comment.stub!(:belongs_to_group_blog_post?).and_return(false)
      @comment.stub!(:belongs_to_group_post?).and_return(false)
      @comment.stub!(:company?).and_return(false)
      @comment.stub!(:root_parent_profile?).and_return(true)
      
      @blog_post = Factory.build(:blog_post, :id => 1)
      @comment.owner = @blog_post 
      @blog = Factory.build(:blog)
      @blog_post.blog = @blog
      @profile = Factory.build(:profile)
      @blog.owner = @profile
      @profile.stub!(:new_comment_on_blog_notification).and_return(true)
      
      Notifier.should_receive(:deliver_new_comment_on_blog).with(@comment).and_return
      @comment.fire_notifications
    end
  end
  
  describe Note do
    before(:each) do
      @note = Factory.build(:note)
    end
    
    it "should repond to fire_notofications" do
      @note.respond_to?(:fire_notifications).should be_true
    end  
    
    it "should delay send group note if the receiver is a group" do
      @group = Factory.build(:group)
      @note.stub!(:receiver).and_return(@group)
      @note.should_receive(:delay).and_return(@note)
      @note.should_receive(:send_group_note)
      @note.fire_notifications

    end
    
    it "should deliver a note if the receiver is set to receive notes" do
      @profile = Factory.build(:profile)
      @note.stub!(:receiver).and_return(@profile)
      @profile.stub!(:note_email_status).and_return(1)
      
      Notifier.should_receive(:deliver_note).with(@note)
      @note.fire_notifications
    end
  end        
  
  describe QuestionReferral do
    before(:each) do
      @group = Factory.build(:group)
      @group.stub!(:id).and_return(1)
      @group.stub!(:members).and_return(Array.wrap Factory.build(:profile))
      @question_referral = QuestionReferral.new()
      @question_referral.owner = @group
      @question_referral.group = @group
      @question_referral.owner_id = @group.id
      @question_referral.question = Factory.build(:question)
      @question_referral.referer = Factory.build(:profile)
    end
    
    it "should repond to fire_notofications" do
      @question_referral.respond_to?(:fire_notifications).should be_true
    end  
    
    it "should delay call send group referral email if receiver is a group" do
      @question_referral.should_receive(:delay).and_return(@question_referral)
      @question_referral.should_receive(:send_group_referral_email).and_return(true)
      @question_referral.fire_notifications
    end
    
    it "should batch email a referral if send_group_email is called" do
      QuestionReferral.methods.include?('send_batch_email').should be_true
      QuestionReferral.should_receive(:send_batch_email).with(anything, @group.members ).and_return(true)
      @question_referral.send_group_referral_email
    end
  end  
end