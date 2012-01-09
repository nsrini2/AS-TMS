# require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
# 
# describe "After the creation of" do
#   before(:each) do
#     @user = mock_model(User, :email => "iwantemail@bla.com")
#     @profile = mock_model(Profile,
#       :user => @user,
#       :email => @user.email,
#       :active? => true,
#       :last_login_date => nil)
#     @user.stub!(:profile => @profile)
# 
#     @membership = mock_model(GroupMembership, :wants_notification_for? => true, :member => @user)
#     @group = mock_model(Group, :group_memberships => [@membership], :name => "Awesome")
# 
#     @observer = GeneralObserver.instance
#   end
# 
#   describe "an Abuse (shady) we" do
#     it "should deliver new abuse email only to admins" do
#       @admin = mock_model(Profile, :user => mock_model(User, :email => "iwantadminemail@bla.com"))
#       @shady = mock_model(Abuse)
#       @admin.stub!(:email => @admin.user.email)
#       Profile.stub!(:include_shady_admins => [@admin])
#       BatchMailer.should_receive(:mail).with(@shady, [@admin.email])
#       BatchMailer.should_not_receive(:mail).with(@shady, [@user.email])
#       @observer.after_create( @shady )
#     end
#   end
# 
#   describe "an Answer we" do
#     before(:each) do
#       @answer = mock_model(Answer, :question => mock_model(Question))
#     end
#     after(:each) do
#       @observer.after_create( @answer )
#     end
#     it "should deliver email to the author of the question who wants per answer notification" do
#       @answer.question.stub!(:per_answer_notification => true, :watchers => [])
#       Notifier.should_receive(:deliver_answer_to_question).with(@answer)
#     end
#     
#     it "should deliver email to those watching the question" do
#       @answer.question.stub!(:per_answer_notification => false, :watchers => [mock_model(Profile, :watched_question_answer_email_status => 1, :email => "iwant@bla.com")])
#       Notifier.should_receive(:deliver_watched_question_answer).with(@answer)
#     end
#   end
# 
#   describe "a Comment we" do
#     before(:each) do
#       @comment = mock_model(Comment)
#       
#       @comment.stub!(:belongs_to_group_blog_post?).and_return(false)
#     end
#     after(:each) do
#       @observer.after_create( @comment )
#     end
#     it "should deliver email to with the new comment if it's a comment on a group blog post" do
#       @comment.stub!(:belongs_to_group_blog_post?).and_return(true)
#       Notifier.should_receive(:deliver_new_comment_on_group_blog_post).with(@comment) 
#     end
#     it "should deliver email to with the new comment if it's a comment on a group post" do
#       @comment.stub!(:belongs_to_group_post?).and_return(true)
#       Notifiers::Group.should_receive(:deliver_new_comment_on_group_post).with(@comment) 
#     end    
#   end
# 
#   describe "a Group Invitation we" do
#     before(:each) do
#       @invitation = mock_model(GroupInvitation, :receiver => @profile)
#     end
#     after(:each) do
#       @observer.after_create(@invitation)
#     end
#     it "should deliver email invitation to a user who wants notifications" do
#       @profile.stub!(:group_invitation_email_status => true)
#       Notifier.should_receive(:deliver_group_invitation).with(@invitation)
#     end
#     it "should not deliver email invitation to a user who does not want notifications" do
#       @profile.stub!(:group_invitation_email_status => false)
#       Notifier.should_not_receive(:deliver_group_invitation)
#     end
#   end
# 
#   describe "a Group Blog Post we" do
#     before(:each) do
#       @group.stub!(:blog).and_return(mock_model(Blog, :owner_type => "Group", :owner => @group))
#       @group_blog_post = mock_model(BlogPost, :blog => @group.blog, :authored_by? => false)
#     end
#     after(:each) do
#       @observer.after_create(@group_blog_post)
#     end
#     it "should setup a delayed delivery of email to a member who wants notifications" do
#       BlogPost.should_receive(:delay).and_return(BlogPost)
#       BlogPost.should_receive(:send_group_blog_post).with(@group_blog_post.id).and_return(true)
#     end
#   end
# 
#   describe "a Group Talk Post we" do
#     before(:each) do
#       @post = mock_model(GroupPost, :group => @group, :authored_by? => false)
#     end
#     after(:each) do
#       @observer.after_create(@post)
#     end
#     it "should delay send the group post" do
#       @post.should_receive(:delay).and_return(@post)
#       @post.should_receive(:send_group_post)
#     end
#   end
# 
#   describe "a Group Note we" do
#     before(:each) do
#       @note = mock_model(Note, :authored_by? => false)
#       @note.stub!(:receiver).and_return(@group)
#     end
#     after(:each) do
#       @observer.after_create(@note)
#     end
#     it "should delayed send the group note" do
#       @note.should_receive(:delay).and_return(@note)
#       @note.should_receive(:send_group_note)
#     end
#   end
# 
#   describe "a Group Question Referral we" do
#     before(:each) do
#       @referral = mock_model(QuestionReferral, :owner => @group, :authored_by? => false)
#     end
#     after(:each) do
#       @observer.after_create(@referral)
#     end
#     it "should deliver email to a member who wants notifications" do
#       @referral.should_receive(:delay).and_return(@referral)
#       @referral.should_receive(:send_group_question_referral)
#     end
#   end
# 
#   describe "a Profile Note we" do
#     before(:each) do
#       @note = mock_model(Note, :authored_by? => false)
#       @note.stub!(:receiver).and_return(@profile)
#     end
#     after(:each) do
#       @observer.after_create(@note)
#     end
#     it "should deliver email to receiver who wants notifications" do
#       @profile.stub!(:note_email_status => 1)
#       Notifier.should_receive(:deliver_note).with(@note)
#     end
#     it "should not deliver email to receiver who does not want notifications" do
#       @profile.stub!(:note_email_status => 0)
#       Notifier.should_not_receive(:deliver_note)
#     end
#   end
# 
#   describe "a Profile Award we" do
#     it "should deliver email to award recipient" do
#       @award = mock_model(ProfileAward)
#       Notifier.should_receive(:deliver_profile_award).with(@award)
#       @observer.after_create(@award)
#     end
#   end
# 
#   describe "a Profile Question Referral we" do
#     before(:each) do
#       @referral = mock_model(QuestionReferral, :owner => @profile, :authored_by? => false)
#     end
#     after(:each) do
#       @observer.after_create(@referral)
#     end
#     it "should deliver email to recipient who wants notifications" do 
#       @profile.stub!(:referral_email_status => 1)
#       Notifier.should_receive(:deliver_referral).with(@referral)
#     end
#     it "should not deliver email to recipient who does not want notifications" do
#       @profile.stub!(:referral_email_status => 0)
#       Notifier.should_not_receive(:deliver_referral)
#     end
#   end
#   
#   describe "a Reply we" do
#     before(:each) do
#       @reply = mock_model(Reply, :answer => mock_model(Answer, :profile => @profile))
#     end
#     after(:each) do
#       @observer.after_create(@reply)
#     end
#     it "should deliver email to recipient who wants notifications" do
#       @reply.answer.profile.stub!(:new_reply_on_answer_notification => true)
#       Notifier.should_receive(:deliver_reply).with(@reply)
#     end
#     it "should not deliver email to recipient who does not want notifications" do
#       @reply.answer.profile.stub!(:new_reply_on_answer_notification => false)
#       Notifier.should_not_receive(:deliver_reply)
#     end
#   end
#   
#   describe "a Getthere Booking we" do
#     before(:each) do
#       @booking = mock_model(GetthereBooking, :profile => mock_model(Profile), :past? => false)
#     end
#     after(:each) do
#       @observer.after_create(@booking)
#     end
#     
#     it "should deliver email to recipient who wants notifications" do
#       @booking.profile.stub!(:travel_email_status => true)
#       Notifiers::Travel.should_receive(:deliver_new_getthere_booking).with(@booking).and_return(true)
#     end
#     it "should not deliver email to a recipient who does not want notifications" do
#       @booking.profile.stub!(:travel_email_status => false)
#       Notifiers::Travel.should_not_receive(:deliver_new_getthere_booking)
#     end
#     it "should not deliver emails on past trips even if notifications are turned on" do
#       @booking.profile.stub!(:travel_email_status => true)
#       @booking.stub!(:past?).and_return(true)
#       Notifiers::Travel.should_not_receive(:deliver_new_getthere_booking)
#     end
#   end
# end
# 
# describe "After saving" do
#   before(:each) do
#     @user = mock_model(User, :email => "iwantemail@bla.com")
#     @profile = mock_model(Profile,
#       :user => @user,
#       :email => @user.email,
#       :active? => true,
#       :last_login_date => nil)
#     @user.stub!(:profile => @profile)
# 
#     @observer = GeneralObserver.instance
#   end
# 
#   # Functionality moved to Notifications::Profile
#   # REMOVE AFTER 2012-01-01
#   # 
#   # describe "a Profile we" do
#   #   it "should deliver welcome email for new users" do
#   #     @profile.stub!(:new_user? => true)
#   #     Notifier.should_receive(:deliver_welcome).with(@user)
#   #     @observer.after_create(@profile)
#   #   end
#   # end
#   # 
#   # describe "a Profile we" do
#   #   it "should deliver welcome email for new users whose status has been changed to Active or Activate on login" do
#   #     @profile.stub!(:new_user? => true, :status_was => 0)
#   #     Notifier.should_receive(:deliver_welcome).with(@user)
#   #     @observer.after_save(@profile)
#   #   end
#   # end
# end
# 
# describe "After updating" do
#   before(:each) do
#     @answer = mock_model(Answer, :profile => @profile, :best_answer => true, :attribute_modified? => true)
#     @observer = GeneralObserver.instance
#   end
#   describe "an Answer we" do
#     before(:each) do
#       @question = mock_model(Question, :is_closed? => false)
#       Question.should_receive(:find_by_id).and_return(@question)
#       
#       @answer = mock_model(Answer, :profile => @profile, :best_answer => true, :attribute_modified? => true, :question_id => @question)
#     end
#     after(:each) do
#       @observer.after_update(@answer)
#     end
#     it "should deliver email to the author of a best answer who wants notifications" do
#       # MM2: For some reason it appears 'best answer' emails can only be sent when a question is 'closed'
#       @question.stub!(:is_closed?).and_return(true)
#       
#       @answer.profile.stub!(:best_answer_email_status => 1)
#       Notifier.should_receive(:deliver_best_answer).with(@answer)
#     end
#     it "should not deliver email the author of a best answer who does not want notifications" do
#       @answer.profile.stub!(:best_answer_email_status => 0)
#       Notifier.should_not_receive(:deliver_best_answer)
#     end
#   end
#   
#   describe "a Group we" do
#     it "should deliver email to the new owner of a group" do
#       @group = mock_model(Group, :attribute_modified? => true)
#       Notifier.should_receive(:deliver_group_owner).with(@group)
#       @observer.after_update(@group)
#     end
#   end
#   
#   describe "a Group Membership we" do
#     it "should deliver email to the new moderator of a group" do
#       @membership = mock_model(GroupMembership, :profile_id => 1, :group => mock_model(Group, :owner_id => 2), :moderator => true, :attribute_modified? => true)
#       Notifier.should_receive(:deliver_group_moderator).with(@membership)
#       @observer.after_update(@membership)
#     end
#   end
# end