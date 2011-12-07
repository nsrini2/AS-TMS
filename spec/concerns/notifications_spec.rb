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
end