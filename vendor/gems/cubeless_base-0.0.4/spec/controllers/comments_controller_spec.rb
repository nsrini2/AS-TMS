require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe CommentsController do

  before(:each) do
    pending "great 2011 migration"
    
    @comment = mock_model(Comment)
    Comment.stub!(:find => @comment)
  end

  it "does not allow member to edit or update another users comment" do
    controller.should_receive(:render).with(:update).never
    login_as_direct_member
    controller.stub!(:parent)
    @comment.stub!(:editable_by? => false)
    lambda{
      get :edit, :id => 1
    }.should raise_error(Exceptions::UnauthorizedEdit)
    lambda{
      put :update, :id => 1
    }.should raise_error(Exceptions::UnauthorizedEdit)
  end

  it "allows authors and admins to edit or update an comment" do
    controller.should_receive(:respond_to).exactly(4).times
    controller.stub!(:parent)
    [login_as_direct_member, login_as_shady_admin].each do
      @comment.stub!(:editable_by? => true)
      get :edit, :id => 1, :format => :js
      put :update, :id => 1, :format => :json
    end
  end

end