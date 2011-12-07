require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe VotesController do
  before(:each) do
    login_as_direct_member
    @answer = mock_model(Answer)
    Answer.stub!(:find => @answer)
  end

  it "does not allow a member to vote on their own content" do
    @answer.stub!(:authored_by? => true)
    Vote.should_not_receive(:find_or_create_by_profile_id_and_owner_id_and_owner_type_and_vote_value)
    controller.should_receive(:respond_to).twice
    get :helpful, :question_id => 1, :answer_id => 1, :format => "js"
    get :not_helpful, :question_id => 1, :answer_id => 1, :format => "js"
  end

end