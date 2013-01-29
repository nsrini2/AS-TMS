require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe BlogPost do
  fixtures :blog_posts, :blogs, :groups
  
  
  before(:each) do
    @blog_post = BlogPost.new
    @profile = mock_model(Profile)
    @blog = mock_model(Blog)
    @valid_attributes = {
      :blog => @blog,
      :profile => @profile,
      :title => 'Test',
      :text => 'Testing blog post...',
      :tag_list => 'test'
    }
    @profile.stub!(:has_role? => false)
    @blog_post.stub!(:root_parent => @profile)
    
    @group
  end
  
  it "should create a new instance given valid attributes" do
    @blog_post.attributes = @valid_attributes
    @blog_post.should be_valid
  end
  
  it "should be invalid without a title" do
    @blog_post.attributes = @valid_attributes.except(:title)
    @blog_post.should have(1).error_on(:title)
  end
  
  it "should be invalid without a body (text)" do
    @blog_post.attributes = @valid_attributes.except(:text)
    @blog_post.should have(1).error_on(:text)
  end
  
  it "should be invalid without tags" do
    @blog_post.attributes = @valid_attributes.except(:tag_list)
    @blog_post.should have(1).error_on(:tag_list)
  end
  
  it "should belong to a Blog" do
    @blog_post.attributes = @valid_attributes.except(:blog)
    @blog_post.should have(1).error_on(:blog)
  end
  
  # it "should belong to a Profile" do
  #   # SSJ 2012-08-28 this is no longer true as they can belong to a profile or RSSFeed
  #   @blog_post.attributes = @valid_attributes.except(:profile)
  #   @blog_post.should have(1).error_on(:profile)
  # end
  
  it "should only be authored by the creator" do
    @blog_post.attributes = @valid_attributes
    @blog_post.should be_authored_by(@profile)
    @blog_post.should_not be_authored_by( mock_model(Profile) )
  end
  
  describe "publicized" do
    before(:each) do
      @posts = BlogPost.publicized
    end
      
    it  "should return posts" do    
      assert @posts.size > 0, "Publicized did not find any posts"
    end
    
    it  "should not find company blog posts" do
      assert !@posts.include?(blog_posts(:company)), "publicized returned a company blog post, which it should not"
    end
    
    it "should not find blog posts from private groups" do  
      assert !@posts.include?(blog_posts(:private_group)), "publicized returned a private group blog post, which it should not"
    end
    
    it "should find most recent blog posts from non-private groups" do
      assert_same @posts.first.id, blog_posts(:public_group_newest).id
      assert_same @posts[1].id, blog_posts(:public_group_middle).id
      assert_same @posts.last.id, blog_posts(:public_group_oldest).id
    end 
    
    it "should find public profile blog posts" do
      pending "Showing personal blog posts in publicized has not been implemented."
    end   
  end  
  
  describe "deletion" do
    it "should always allow Shady Admins to delete" do
      @profile.stub!(:has_role? => true)
      @blog_post.should be_deletable_by(@profile)
    end
  
    it "should always allow the blog post author to delete" do
      @blog_post.stub!(:profile => @profile)
      @blog_post.should be_deletable_by(@profile)
    end
    
    it "should not allow a non admin or non author to delete" do
      @blog_post.should_not be_deletable_by(@profile)
    end
  
    describe "on a Group blog post" do
      before(:each) do
        @group = mock_model(Group)
        @group.stub!(:is_owner? => false)
        @group.stub!(:is_moderator? => false)
      end
      it "should allow the group owner to delete" do
        @blog_post.stub!(:root_parent => @group)
        @group.stub!(:is_owner? => true)
        @blog_post.should be_deletable_by(@profile)
      end
  
      it "should allow the moderators to delete" do
        @blog_post.stub!(:root_parent => @group)
        @group.stub!(:is_moderator? => true)
        @blog_post.should be_deletable_by(@profile)
      end
      
      it "should not allow non moderator or non owner to delete" do
        @blog_post.should_not be_deletable_by(@profile)
      end
    end
    
    describe "on a News blog post" do
      before(:each) do
        @news = News.instance
        @blog_post.stub!(:root_parent => @news)
      end
      
      it "should allow the post owner to delete" do
        @blog_post.stub!(:root_parent => @news)
        @blog_post.stub!(:profile => @profile)
        @blog_post.should be_deletable_by(@profile)
      end
  
      it "should not allow non shady admin or non owner to delete" do
        @blog_post.should_not be_deletable_by(@profile)
      end
    end
  
  end
  
  describe "send group blog post" do
    before(:each) do
      @group = mock_model(Group)
      @blog.stub!(:owner).and_return(@group)
      @blog_post.stub!(:blog).and_return(@blog)
      @blog_post.stub!(:id).and_return(1064)
      BlogPost.stub!(:find).with(@blog_post.id).and_return(@blog_post)
     
      @memberships = []
      @group.stub!(:group_memberships).and_return(@memberships)
    end
    after(:each) do
      BlogPost.send_group_blog_post(@blog_post.id)
    end
    it 'should find the blog_post by id' do
      pending
      BlogPost.should_receive(:find).with(1064).and_return(@blog_post)
    end  
    it "should deliver the email via batch mail" do
      pending
      @member = mock_model(User, :email => "test@test.com")
      @memberships << mock_model(GroupMembership, :wants_notification_for? => true, :member => @member)
      BatchMailer.should_receive(:mail).with(@blog_post, ["test@test.com"])
    end
    it "should not deliver email to a member who does not want notifications" do
      pending
      @membership = mock_model(GroupMembership, :wants_notification_for? => false)
      BatchMailer.should_not_receive(:mail)        
    end
    it "should not deliver email to the author" do
      pending
      @blog_post.stub!(:authored_by? => true)
      BatchMailer.should_not_receive(:mail)
    end
  end
end