require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe GroupsController do
  

  before(:each) do
    request.env["HTTP_REFERER"] = "/"
    @g = mock_model(Group, :name => "Hello Kitty Fan Club")
    login_as_direct_member
    # Group.should_receive(:find_by_id).and_return(@g)
    Group.stub!(:find_by_id).and_return(@g)
  end

  it "should allow group moderators and admins to access mass mail" do
    @g.should_receive(:editable_by?).and_return(true)
    get :mass_mail, :id => 1
    assigns[:mailer].should_not be_nil
  end

  it "should allow moderators and admins to send a mass email" do
    @g.should_receive(:editable_by?).and_return(true)
    @g.should_receive(:delay).and_return(@g)
    @g.should_receive(:send_mass_mail).with(controller.current_profile.id, "blah", "blah", :test_enabled => nil)
    controller.current_profile.stub!(:email => 'blah@blah.com')
    post :mass_mail, :id => 1, :mailer => {:subject => 'blah', :body => 'blah'}
  end

  it "should not allow non moderators to access or send mass mail" do
    @g.should_receive(:editable_by?).and_return(false)
    lambda{
      get :mass_mail, :id => 1
    }.should raise_error(Exceptions::UnauthorizedEdit)
  end
  
  it "should allow the owner to remove a member" do
    gm = mock_model(GroupMembership)
    gm.stub!(:find_by_profile_id).and_return(gm)
    gm.stub!(:destroy).and_return(gm)
    @g.should_receive(:owner).and_return(controller.current_profile)
    @g.should_receive(:group_memberships).and_return(gm)
    @g.stub!(:is_private?).and_return(false)
    post :remove_member, :id => 1, :profile_id => 1
  end
  
  it "should allow the shady admin to remove a member" do
    gm = mock_model(GroupMembership)
    gm.stub!(:find_by_profile_id).and_return(gm)
    gm.stub!(:destroy).and_return(gm)
    @g.should_receive(:owner).and_return(mock_model(Profile))
    @g.should_receive(:group_memberships).and_return(gm)
    @g.stub!(:is_private?).and_return(false)
    login_as_shady_admin
    post :remove_member, :id => 1, :profile_id => 1
  end

  it "should remove watches when removing a member from a private group" do
    pending "great 2011 migration"
    
    gm = mock_model(GroupMembership)
    gm.stub!(:find_by_profile_id).and_return(gm)
    gm.stub!(:destroy).and_return(gm)
    @g.should_receive(:owner).and_return(controller.current_profile)
    @g.should_receive(:group_memberships).and_return(gm)
    @g.stub!(:is_private?).and_return(true)
    Watch.should_receive(:destroy_all).with(["watchable_type = ? and watchable_id = ? and watcher_id = ?", 'Group', @g.id, "1"])
    post :remove_member, :id => 1, :profile_id => 1
  end

  it "should not allow non owner and non admin to remove a member" do
    pending "great 2011 migration"
    
    @g.should_receive(:owner).and_return(mock_model(Profile))
    @g.should_not_receive(:group_memberships)
    @g.stub!(:is_private?).and_return(false)
    post :remove_member, :id => 1, :profile_id => 1
  end

  it "should not allow non owners to change moderator settings" do
    @g.should_not_receive(:make_unmoderated)
    @g.should_receive(:owner).and_return(mock_model(Profile))
    post :moderator_settings, :id => 1, :moderator_option => 'moderators_all'
  end

  it "should not allow non owners or non admins to access ownership list" do
    @g.should_receive(:owner).and_return(mock_model(Profile))
    controller.should_receive(:redirect_to)
    get :ownership, :id => 1
  end

  it "should not allow owner to transfer ownership to non member" do
    pending "great 2011 migration"
    
    @g.should_receive(:owner).and_return(controller.current_profile)
    @g.stub!(:members)
    @g.members.should_receive(:find_by_id).and_return(nil)
    @g.should_not_receive(:transfer_ownership_to!)
    post :assign_owner, :id => 1, :profile_id => 1
  end      

  it "should not allow non owners or non admins to access the list of people who are not moderators" do
     @g.should_not_receive(:members)
     @g.should_receive(:editable_by?).and_return(false)
     lambda{
       get :filter_mods, :id => 1
     }.should raise_error(Exceptions::UnauthorizedEdit)
  end

  it "should not delete other members watch when quitting private group" do
    @g.should_receive(:is_private?).and_return(true)
    Watch.should_receive(:destroy_all).with(["watchable_type = ? and watchable_id = ? and watcher_id = ?", 'Group', @g.id, controller.current_profile.id])
    post :quit, :id => 1
  end

  it "should not allow non owners to change the group type" do
    @g.stub!(:editable_by? => false)
    controller.should_not_receive(:respond_to)
    lambda { 
      put :update, :id => 1, :group => { :group_type => 1 }
    }.should raise_error(Exceptions::UnauthorizedEdit)
  end
  
  it "should allow the group owner to change the group type" do
    pending "great 2011 migration"

    @g.stub!(:editable_by? => true)
    controller.stub!(:is_editable?).and_return(true)
    controller.stub!(:create_or_update_group_photo)
    @g.should_receive(:update_attributes)
    controller.should_receive(:respond_to)
    put :update, :id => 1, :group => { :group_type => 1 }, :asset => { :uploaded_data => mock(File) }, :format => :json
  end
  
  it "should allow shady admins to change the group type" do
    pending "great 2011 migration"
    
    @g.stub!(:editable_by? => true)
    controller.stub!(:is_editable?).and_return(true)
    controller.stub!(:create_or_update_group_photo)
    @g.should_receive(:update_attributes)
    controller.should_receive(:respond_to)
    put :update, :id => 1, :group => { :group_type => 1 }, :asset => { :uploaded_data => mock(File) }, :format => :json
  end

end