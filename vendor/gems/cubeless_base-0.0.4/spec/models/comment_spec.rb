require File.dirname(__FILE__) + '/../spec_helper'

describe Comment do
  
  before(:each) do
    @comment = Comment.new
  end
  
  describe "belonging to Group Posts" do
    before(:each) do
      @group_post = GroupPost.new
    end
    
    it "should belong to group post if it does" do
      @comment.owner = @group_post
      @comment.should be_belongs_to_group_post
    end
    it "should not belong to group post if it does not" do
      @comment.owner = nil
      @comment.should_not be_belongs_to_group_post
    end
  end
  
end