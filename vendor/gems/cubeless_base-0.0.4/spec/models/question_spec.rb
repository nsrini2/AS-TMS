require File.dirname(__FILE__) + '/../spec_helper'

describe Question do
  def valid_attributes
    {:question => "What's up?",
     :category => Config[:question_categories].first,
     :open_until => Time.now.advance(:days => 3)}
  end
  
  
  before(:each) do
    @question = Question.new(valid_attributes)
  end
  
  describe "validations" do
    it "should be valid with valid attributes" do
      @question.should be_valid
    end
    
    it "should validate the question" do
      @question.question = nil
      @question.should_not be_valid
    end
    
    describe "category" do
      it "should be valid with categories with spaces" do
        category = "This is so cool"
        
        categories = Config[:question_categories]
        categories << category
        
        Config.merge!({:question_categories => categories})
          
        @question.category = category
        @question.should be_valid
      end
    end
  end
  
  describe "open and closed" do
    it "should be open if it's open until after today" do
      @question.should be_is_open
    end
    it "should not be open if it's open until yesterday" do
      @question.open_until = Time.now.advance(:days => -1)
      @question.should_not be_is_open
    end
    # it "should be open if there is no open until date" do
    #   @question.open_until = nil
    #   @question.should be_is_open
    # end
  end
  
end