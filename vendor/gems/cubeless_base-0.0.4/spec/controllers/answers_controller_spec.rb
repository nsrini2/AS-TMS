require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe AnswersController do

  before(:each) do
    @answer = mock_model(Answer, :question => mock_model(Question), :to_json => "")
    Answer.stub!(:find_by_id => @answer)
  end
  
  describe 'as a Shady Admin I' do
    before(:each) do
      login_as_shady_admin
      @answer.stub!(:editable_by? => true)
    end

    it "should be able to update an answer" do
      pending "great 2011 migration"
      
      controller.should_receive(:respond_to)
      put :update, :id => 1
    end

    it "should be able to delete an answer" do
      @answer.should_receive(:destroy)
      delete :destroy, :id => 1
    end
  end
  
  describe 'as a Direct Member I' do
    before(:each) do
      login_as_direct_member
    end
    
    it "should be able to edit my answer" do
      pending "great 2011 migration"
      
      @answer.stub!(:editable_by? => true)
      controller.should_receive(:respond_to)
      get :edit, :id => "1"
    end
    it "should be able to update my answer" do
      pending "great 2011 migration"
      
      @answer.stub!(:editable_by? => true)
      controller.should_receive(:respond_to)
      put :update, :id => 1
    end
    
    it "should not be able to edit another members answer" do
      @answer.stub!(:editable_by? => false)
      controller.should_not_receive(:respond_to)
      lambda{
        get :edit, :id => "1"
      }.should raise_error(Exceptions::UnauthorizedEdit)
    end
    it "should not be able to update another members answer" do
      controller.should_not_receive(:respond_to)
      @answer.stub!(:editable_by? => false)
      lambda{
        put :update, :id => 1
      }.should raise_error(Exceptions::UnauthorizedEdit)
    end
    
    it "should not be able to make my own answer as 'Best Answer'" do
      pending "great 2011 migration"
      
      @answer.stub!(:authored_by? => true)
      @answer.question.stub!(:authored_by? => true)
      controller.should_receive(:respond_to)
      @answer.should_not_receive(:save)
      get :vote_best_answer, :id => 1, :format => :json
    end

    it "should not be able to delete an answer" do
      @answer.should_not_receive(:destroy)
      delete :destroy, :id => 1
    end

  end

end