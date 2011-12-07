require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe GroupPostsController do
  
  before(:each) do
    request.env["HTTP_REFERER"] = "/"
    @g = mock_model(Group, :name => "Hello Kitty Fan Club", :is_private? => false)
    login_as_direct_member
    Group.should_receive(:find_by_id).and_return(@g)
  end

  it "should not allow non group members or non admins to view group talk posts" do
    @g.should_not_receive(:group_posts)
    @g.stub!(:is_member?).and_return(false)
    get :index
  end

  it "should allow admins and members to access group talk posts" do
    @g.should_receive(:group_posts).and_return(GroupPost)
    @g.stub!(:is_member?).and_return(true)
    get :index
  end
  
end