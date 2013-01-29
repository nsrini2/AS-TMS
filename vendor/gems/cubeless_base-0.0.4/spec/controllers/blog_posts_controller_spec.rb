require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe BlogPostsController do

  before(:each) do
    @post = mock_model(BlogPost)
    BlogPost.stub!(:find => @post)
    @post.stub!(:blog => mock_model(Blog))
    controller.stub!(:add_to_errors => true)
  end

  it "does not allow member to edit or update another users blog post" do
    controller.should_receive(:render).with(:template).never
    login_as_direct_member
    controller.stub!(:parent)
    @post.stub!(:editable_by? => false)
    lambda{
      get :edit, :id => 1
    }.should raise_error(Exceptions::UnauthorizedEdit)
    lambda{
      put :update, :id => 1, :blog_post => {:tag_list => "hello"}
    }.should raise_error(Exceptions::UnauthorizedEdit)
  end

  it "allows authors and shady admins to edit a blog post" do
    @post.should_receive(:update_attributes).twice
    [login_as_direct_member, login_as_shady_admin].each do
      controller.stub!(:parent)
      @post.stub!(:editable_by? => true)
      get :edit, :id => 1, :commit => "commit"
      put :update, :id => 1, :commit => "commit", :blog_post => {:tag_list => "hello"}
    end
  end

end