require File.dirname(__FILE__) + '/../spec_helper'

describe SemanticMatcher do
  before(:all) do
    Kernel.const_set(Config[:semantic_matcher], "MysqlSemanticMatcher") 
  end
  
  before(:each) do  
    @matcher = MysqlSemanticMatcher.new
  end
  
  describe "weak terms" do
    describe "character limitations" do
      it "should be identified if they have less than 3 characters" do
        @matcher.weak_term?("ab").should be_true
      end
      it "should not be flagged if they have 3 characters" do
        @matcher.weak_term?("abc").should be_false
      end
      it "should not be flagged if they have more than 3 characters" do
        @matcher.weak_term?("abcdefg")
      end
    end
  end
  
  describe "get terms set" do
    it "should return a blank set by default" do
      @matcher.get_terms_set("").should == Set.new
    end
    it "should return terms" do
      @terms = @matcher.get_terms_set("apple banana")
      @terms.size.should == 2
      @terms.member?("apple").should be_true
      @terms.member?("banana").should be_true      
    end
  end
  
  it "should yield terms" do
    @matcher.yield_terms("apple banana") { |term, term_length|
      %w(apple banana).should include(term)
    }
  end
  
  # MM2: The '??' removal pattern seems a little strange to me
  it "should remove terms" do
    @matcher.remove_terms("apple banana", "apple").should == " ?? banana "
  end
  
  it "should get the phrase length" do
    @matcher.phrase_length_at?(%w(apple banana), 0).should == 1
  end
  
  describe "rematch questions" do
    before(:each) do
      @query = mock("sql", :execute => true)
    end
    
    def rematch
      @matcher.rematch_questions
    end
    
    it "should prepare a delete query" do
      @matcher.should_receive(:db_prepare).with("delete qpm from question_profile_matches qpm join questions q on q.id=qpm.question_id where q.open_until <= current_date() and q.directed_question=0").and_return(@query)
    
      rematch
    end
    it "should match questions to profiles for each open question" do
      @question = mock_model(Question)
      @questions = [@question]
      
      Question.should_receive(:open_questions).and_return(@questions)
      @matcher.should_receive(:match_question_to_profiles).with(@question)
      
      rematch
    end
  end
  
  describe "class methods" do
    it "should fetch the default instance" do    
      SemanticMatcher.default.class.to_s.should == "MysqlSemanticMatcher"
    end
  
    it "should get the max matched assigned for a question" do
      SemanticMatcher.question_match_max_assigned.should == 50
    end
  end

end