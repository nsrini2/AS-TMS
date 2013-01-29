require File.dirname(__FILE__) + '/../spec_helper'

# Included into the Application Controller
# Dependent on controller type things like params, request, etc
describe ParentResource do
  
  class PRController < ApplicationController
    include ParentResource
  end
  
  before(:each) do
    @path_params = {}
    @request = mock("Request", :path_parameters => @path_params)
    
    @pr = PRController.new
    @pr.stub!(:request).and_return(@request)
  end
  
  describe "parents hash" do
    it "should return the current parents hash if one is present" do
      @pr.instance_variable_set("@parents_hash", {:mark => "cool"})
      @pr.parents_hash.should == {:mark => "cool"}
    end
    it "should return an empty hash if there is no current hash and no request path params" do
      @pr.parents_hash.should == {}
    end
    it "should return a hash of the parents based on the path params with _id in them" do
      @path_params = {"question_id" => 12, "answer" => 4}
      @request.stub!(:path_parameters).and_return(@path_params)
      
      @pr.parents_hash.should == {"question" => 12}
    end
    it "should return a hash of the mutli level parents based on the path params with _id in them" do
      @path_params = {"blog_id" => 12, "comment_id" => 4, "id" => 3}
      @request.stub!(:path_parameters).and_return(@path_params)
      
      @pr.parents_hash.should == {"blog" => 12, "comment" => 4}
    end
  end
  
  describe "parents array" do
    before(:each) do
      @path_params = {"blog_id" => 12, "comment_id" => 4, "id" => 3}
      @request.stub!(:path_parameters).and_return(@path_params)
      @request.stub!("path").and_return("/blogs/12/comments/4/replies/3")
      
      @pr.stub!(:parents_hash).and_return({"blog" => 12, "comment" => 4})
    end
    
    it "should return a previously set parents_array if one exists" do
      @pr.instance_variable_set("@parents_array", ["mark", "cool"])
      @pr.parents_array.should == ["mark", "cool"]
    end
    
    it "should return an array based on the parents_hash" do
      @pr.parents_array.should == [{:name=>"blog", :id=>12}, {:name=>"comment", :id=>4}]
    end
  end
  
  describe "parent" do
    before(:each) do
      @path_params = {"blog_id" => 12, "comment_id" => 4, "id" => 3}
      @request.stub!(:path_parameters).and_return(@path_params)
      @request.stub!("path").and_return("/blogs/12/comments/4/replies/3")      
      
      @comment = mock_model(Comment)
      Comment.stub!(:find_by_id).and_return(@comment)
      
      @blog = mock_model(Blog)
      Blog.stub!(:find_by_id).and_return(@blog)
    end

    it "should return a previously set parent" do
      @pr.instance_variable_set("@parent", {"-1" => @comment})
      @pr.parent.should == @comment
    end
    it "should return a parent" do
      @pr.parent.should == @comment
    end
    it "should return a parent further up the ancestory" do
      @pr.parent(-2).should == @blog
    end
    it "should return nil if no parents are at that level" do
      @pr.parent(-3).should == nil
    end
  end 
  
  describe "parents" do
    before(:each) do
      @path_params = {"blog_id" => 12, "comment_id" => 4, "id" => 3}
      @request.stub!(:path_parameters).and_return(@path_params)
      @request.stub!("path").and_return("/blogs/12/comments/4/replies/3")      
      
      @comment = mock_model(Comment)
      Comment.stub!(:find_by_id).and_return(@comment)
      
      @blog = mock_model(Blog)
      Blog.stub!(:find_by_id).and_return(@blog)
    end
    
    it "should return previously set parents" do
      @pr.instance_variable_set("@parents", ["mark"])
      @pr.parents.should == ["mark"]
    end
    it "should return the parents from the parents array" do
      @pr.parents.should == [@blog, @comment]
    end      
  end
  
end