require File.dirname(__FILE__) + '/../spec_helper'

describe AbusesController do
  
  before(:each) do
    login_as_direct_member
    
    @abuse = Abuse.new
    Abuse.stub!(:new).and_return(@abuse)
  end
  
  describe "POST /abuse" do
    before(:each) do        
      @profile = Profile.new
      @profile.stub!(:id).and_return(321)
    end
    
    describe "groups" do
      before(:each) do
        @group = Group.new
        Group.stub!(:find).and_return(@group)

        @group.stub!(:id).and_return(451)        
        @group.stub!(:owner_id).and_return(@profile)
        
        @controller.stub!(:parent).and_return(@group)
      end
      
      it "should find the group" do
        # Group.should_receive(:find).with(@group.id).and_return(@group)
        
        post :create, :group_id => @group.id, :format => :json
      end
      it "should get the group's owner id" do
        @group.should_receive(:owner_id).and_return(@profile.id)
        
        post :create, :group_id => @group.id, :format => :json
      end
      it "should be successful" do
        post :create, :group_id => @group.id, :format => :json
        response.should be_success
      end
    end # groups
    
    describe "questions" do
      before(:each) do
        @question = Question.new
        @question.stub!(:id).and_return(12)
        Question.stub!(:find).and_return(@question)
        
        @question.stub!(:profile_id).and_return(@profile.id)
        
        @controller.stub!(:parent).and_return(@question)
      end
      
      it "should find the question" do
        # Question.should_receive(:find).with(@question.id).and_return(@question)
        post :create, :question_id => @question.id, :format => :json
      end
      it "should get the question's profile id" do
        @question.should_receive(:profile_id).and_return(@profile.id)
        post :create, :question_id => @question.id, :format => :json
      end
      it "should be successful" do
        post :create, :question_id => @question.id, :format => :json
        response.should be_success
      end
    end
  end
  
end