require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe GroupInvitationsController do

  before(:each) do
    login_as_direct_member
    @group_invitation = mock_model(GroupInvitation)
    @group_invitation_request = mock_model(GroupInvitationRequest, :group => mock_model(Group))
  end

  it "should not allow users to decline other users group invitations" do
    controller.current_profile.stub!(:received_invitations)
    controller.current_profile.received_invitations.should_receive(:find).and_return(nil)
    lambda{
      delete :destroy, :id => 1
    }.should raise_error
  end

  it "should allow receivers to destroy their invitations" do
    @group_invitation.should_receive(:destroy).and_return(true)
    controller.current_profile.stub!(:received_invitations)
    controller.current_profile.received_invitations.should_receive(:find).and_return(@group_invitation)
    delete :destroy, :id => 1
  end

  it "should only allow group members to approve invitation requests" do
    GroupInvitationRequest.should_receive(:find_by_id).and_return(@group_invitation_request)
    @group_invitation_request.group.should_receive(:editable_by?).and_return(false)
    @group_invitation_request.should_not_receive(:accept)
    lambda{
      post :accept_invitation_request, :id => 1
    }.should raise_error(Exceptions::UnauthorizedEdit)
    flash[:notice].should be_nil
  end

  it "should only allow group members to decline invitation requests" do
    GroupInvitationRequest.should_receive(:find_by_id).and_return(@group_invitation_request)
    @group_invitation_request.group.should_receive(:editable_by?).and_return(false)
    @group_invitation_request.should_not_receive(:destroy)
    lambda{
      post :decline_invitation_request, :id => 1
    }.should raise_error(Exceptions::UnauthorizedEdit)
    flash[:notice].should be_nil
  end

end