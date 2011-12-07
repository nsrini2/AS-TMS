require File.dirname(__FILE__) + '/../spec_helper'

describe "PandaInitializer" do
  describe "Cubeless JSON hack" do
    before(:each) do
      @question = Question.new(:question => "Hello?")
    end
    
    it "should turn an AR object into JSON" do
      JSON.parse(@question.to_json)["question"]["question"].should == "Hello?"
      #"{\"question\":{\"directed_question\":false,\"updated_at\":null,\"category\":null,\"question\":\"Hello?\",\"daily_summary_email\":false,\"author_viewed_at\":null,\"open_until\":null,\"answers_poi_count\":0,\"answers_count\":0,\"profile_id\":null,\"per_answer_notification\":false,\"created_at\":null}}"
    end
    it "should allow methods to be assigned" do
      @now = "2010-01-01".to_time
      @question.open_until = @now
      @now_string = "2010-01-01T00:00:00Z"
      JSON.parse(@question.to_json(:methods => "is_open?"))["question"]["is_open?"].should == false
      #"{\"question\":{\"is_open?\":false,\"directed_question\":false,\"updated_at\":null,\"category\":null,\"question\":\"Hello?\",\"daily_summary_email\":false,\"author_viewed_at\":null,\"open_until\":\"#{@now_string}\",\"answers_poi_count\":0,\"answers_count\":0,\"profile_id\":null,\"per_answer_notification\":false,\"created_at\":null}}"
    end
    it "should handle complex names" do
      @question_referral = QuestionReferral.new
      JSON.parse(@question_referral.to_json)["question_referral"]["created_at"].should == nil
      #"{\"question_referral\":{\"referer_id\":null,\"question_id\":null,\"owner_id\":null,\"owner_type\":null,\"created_at\":null,\"active\":true}}"
    end
  end
end