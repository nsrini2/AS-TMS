require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe QuestionsController do

  before(:each) do
    request.env["HTTP_REFERER"] = "/"
    @question = mock_model(Question, :to_json => "")
    Question.stub!(:find => @question)
    Question.stub!(:find_by_id => @question)
    Question.stub!(:unscoped).and_return(Question)
    controller.stub!(:add_to_errors => true)
  end

  def do_update
    put :update, :id => 1, :question => {:open_until_1 => Date.today.to_s, :category => 1, :question => 1}, :format => :json
  end

  def do_update_close
    put :update, :id => 1, :question => { :open_until_1 => 1.day.from_now.to_s }, :format => :json
  end

  describe 'as a System Admin I' do
    before(:each) do
      login_as_shady_admin
      @question.stub!(:authored_by? => false, :editable_by? => true, :open_until= => true, :answers_count => 1)
    end
    it "should be able to edit a question" do
      @question.stub!(:question= => true, :category= => true)
      @question.should_receive(:save)
      do_update
    end
    it "should be able to close a question" do
      @question.should_receive(:close)
      get :close, :id => 1
    end
    it "should be able to delete a question" do
      @question.should_receive(:destroy)
      delete :destroy, :id => 1
    end
  end

  describe 'As a Direct Member I' do
    before(:each) do
      login_as_direct_member
    end
    it "should be able to edit my question" do
      @question.stub!(:authored_by? => true, :editable_by? => true, :open_until= => true, :answers_count => 1)
      @question.should_receive(:save)
      do_update
    end
    it "should be able to close my question" do
      @question.stub!(:authored_by? => true, :editable_by? => true)
      @question.should_receive :close
      get :close, :id => 1
    end
    it "should be able to update the close date of my question" do
      @question.stub!(:authored_by? => true, :editable_by? => true, :open_until= => true, :answers_count => 1)
      @question.should_receive(:save)
      do_update_close
    end
    it "should be able to delete my question" do
      @question.stub!(:editable_by? => true)
      @question.should_receive(:destroy)
      delete :destroy, :id => 1
    end
    it "should not be able to edit other members questions" do
      @question.stub!(:editable_by? => false)
      lambda {
        do_update
      }.should raise_error(Exceptions::UnauthorizedEdit)
    end
    it "should not be able to close other members questions" do
      @question.stub!(:authored_by? => false, :editable_by? => false)
      @question.should_not_receive(:close)
      get :close, :id => 1
    end
    it "should not be able to update the close date of other members questions" do
      @question.stub!(:authored_by? => false)
      @question.stub!(:editable_by? => false)
      lambda { do_update_close }.should raise_error(Exceptions::UnauthorizedEdit)
    end
    it "should not be able to delete other members questions" do
      @question.stub!(:editable_by? => false)
      @question.should_not_receive(:destroy)
      lambda {
        delete :destroy, :id => 1
      }.should raise_error(Exceptions::UnauthorizedEdit)
    end
  end

end