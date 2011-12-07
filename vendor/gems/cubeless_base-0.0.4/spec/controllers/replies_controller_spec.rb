require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe RepliesController do

  before(:each) do
    pending "great 2011 migraiton (js formats not passing through)"
    
    login_as_direct_member
    @answer = mock_model(Answer)
    Answer.stub!(:find => @answer)
    
    @reply = mock_model(Reply, :answer => @answer, :text= => true)
    Reply.stub!(:find_by_id).and_return(@reply)
  end

  it "should allow only the Question asker to reply to Answers (new)" do
    controller.should_not_receive(:show_in_popup)
    @answer.stub!(:question => mock_model(Question))
    @answer.question.stub!(:editable_by? => false)
    lambda {
      get :new
    }.should raise_error(Exceptions::UnauthorizedEdit)
  end

  it "should allow only the Question asker to reply to Answers (create)" do
    @question = mock_model(Question)
    @answer.stub!(:question => @question, :question_id => @question.id)
    @answer.question.stub!(:editable_by? => false)
    controller.should_not_receive(:respond_to)
    lambda {
      post :create, :answer_id => 1, :reply => { :text => "hehe"}, :format => :js
    }.should raise_error(Exceptions::UnauthorizedEdit)
  end

  it "should allow the Question asker to reply to Answers(new)" do
    @answer.stub!(:question => mock_model(Question))
    @answer.question.stub!(:editable_by? => true)
    controller.should_receive(:respond_to)
    get :new
  end

  it "should allow the Question asker to reply to Answers(create)" do
    @answer.stub!(:question => mock_model(Question))
    @answer.question.stub!(:editable_by? => true)
    controller.should_receive(:respond_to)
    get :create, :answer_id => 1, :reply => { :text => "hehe"}, :format => :js
  end

  it "should allow only the Question asker to edit replies" do
    Reply.stub!(:find_by_id => mock_model(Reply, :answer => @answer, :text= => true))
    @answer.stub!(:question => mock_model(Question))
    @answer.question.stub!(:editable_by? => false)
    controller.should_not_receive(:respond_to)
    lambda {
      get :edit, :id => 1
    }.should raise_error(Exceptions::UnauthorizedEdit)
  end

  it "should allow only the Question asker to update replies" do
    Reply.stub!(:find_by_id => mock_model(Reply, :answer => @answer, :text= => true))
    @answer.stub!(:question => mock_model(Question))
    @answer.question.stub!(:editable_by? => false)
    controller.should_not_receive(:respond_to)
    lambda {
      post :update, :id => 1, :reply => { :text => "hehe"}
    }.should raise_error(Exceptions::UnauthorizedEdit)
  end

  it "should allow the Question asker to edit replies" do
    Reply.stub!(:find_by_id => mock_model(Reply, :answer => @answer, :text= => true))
    @answer.stub!(:question => mock_model(Question))
    @answer.question.stub!(:editable_by? => true)
    @answer.question.stub!(:is_editable? => true)
    controller.should_receive(:respond_to)
    get :edit, :id => 1, :format => :js
  end

  it "should allow the Question asker to update replies" do
    @answer.stub!(:question => mock_model(Question))
    @answer.question.stub!(:editable_by? => true)
    @answer.question.stub!(:is_editable? => true)
    controller.should_receive(:respond_to)
    post :update, :id => 1, :reply => { :text => "hehe"}, :format => :json
  end

end