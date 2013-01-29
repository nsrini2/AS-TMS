require File.dirname(__FILE__) + '/../spec_helper'

require "semantic_matcher.rb"
require "mysql_semantic_matcher.rb"

# MM2: Having trouble naming this "MysqlSemanticMatcher"
# It somehow complains that the file does not define the right class
# Adding more text to the describe stops this 'helpful' rspec magic

describe "MysqlSemanticMatcher behaviors" do
  before(:all) do
    Kernel.const_set(Config[:semantic_matcher], MysqlSemanticMatcher)
  end
  
  before(:each) do  
    pending "CI issue"
    
    @matcher = MysqlSemanticMatcher.new
  end
  
  describe "questions" do
    before(:each) do
      @question = mock_model(Question, :matchable_text => "apple", :is_open? => true)
      
      @qti = QuestionTextIndex.new
      @qti.stub!(:question).and_return(@question)
      @qti.stub!(:question_id).and_return(@question.id)
      @qti.stub!(:save!).and_return(true)
    end

    describe "updated" do
      before(:each) do
        QuestionTextIndex.stub!(:find_or_create_by_question_id).with(@question.id).and_return(@qti)
      end
      
      def updated
        @matcher.question_updated(@question)
      end
      
      it "should find or create a QuestionTextIndex record for the question" do    
        QuestionTextIndex.should_receive(:find_or_create_by_question_id).with(@question.id).and_return(@qti)
        
        updated
      end
      
      it "should NOT match questions if the question is still open" do
        @question.stub!(:is_open?).and_return(true)
        
        @matcher.should_not_receive(:match_question_to_profiles)
        
        updated
      end
      
      it "should delete matches on closed questions" do
        @question.stub!(:is_open?).and_return(false)
        
        QuestionProfileMatch.should_receive(:delete_all).with(['question_id=?',@question.id])
        
        updated
      end
    end # udpated
    
    describe "deleted" do
      it "should delete all the associated entries" do
        QuestionTextIndex.should_receive(:delete_all).with(['question_id=?',@question.id])
        QuestionProfileMatch.should_receive(:delete_all).with(['question_id=?',@question.id])
        QuestionProfileExcludeMatch.should_receive(:delete_all).with(['question_id=?',@question.id])
        
        @matcher.question_deleted(@question)
      end
    end # deleted
    
    describe "match question to profiles" do
      before(:each) do
        @question.stub!(:profile_id).and_return(1)
      end
      
      def match
        @matcher.match_question_to_profiles(@question)
      end
      
      it "should return if the question is not open" do
        @question.stub!(:is_open?).and_return(false)
        
        match.should be_nil
      end
      
      it "should prep the question text for matching" do
        @matcher.should_receive(:prep_text_for_match_query)
        
        match
      end

      # MM2: Hard to get at this to spec
      # it "should setup matches for ranking items" do
      #   @ps = mock("ps")
      #   
      #   QuestionProfileMatch.should_receive(:find_or_create_by_question_id_and_profile_id).and_return(true)
      #   match
      # end
    end
    
    describe "search" do
      it "should search for the term" do
        @matcher.search_questions(Question, "apple").should == []
      end
    end
    
    describe "profile match deleted" do
      it "should actually not do anything" do
        @question_profile_match = mock_model(QuestionProfileMatch, :question_id => @question.id)
        @matcher.question_profile_match_deleted(@question_profile_match)
      end
    end
  end # question
  
  it "should search profiles" do
    @matcher.search_profiles("apple").should == []
  end
  
  it "should search groups" do
    @matcher.search_groups("apple").should == []
  end
  
  it "should search blog posts" do
    @matcher.search_blog_posts("apple").should == []
  end
  
  describe "profile" do
    before(:each) do
      @profile = mock_model(Profile)
      @pti = mock_model(ProfileTextIndex, :profile_text => "Mark McSpadden", :all_answers_text => "", :answers_text => "")
    end
    
    it "should get profile matched questions" do
      Question.should_receive(:find)
      
      @matcher.get_profile_matched_questions(Question, @profile)
    end
    
    it "should find questions relevant to profile" do
      ProfileTextIndex.should_receive(:find_or_create_by_profile_id).with(@profile.id).and_return(@pti)
      Question.should_receive(:find)
      
      @matcher.find_questions_relevant_to_profile(Question, @profile)
    end
    
    it "should find more questions to answer" do
      Question.should_receive(:find)
      @matcher.find_more_questions_to_answer(Question, @profile)
    end
    
    it "should filter questions relevant to profile" do
      ProfileTextIndex.should_receive(:find_or_create_by_profile_id).with(@profile.id).and_return(@pti)
      @matcher.filter_questions_relevant_to_profile(@profile)
    end
    
    describe "updated" do
      it "should update and save the profile text index" do
        @profile.stub!(:exclude_terms_set).and_return(Set.new)
        @profile.stub!(:matchable_text).and_return("apple")
        
        ProfileTextIndex.should_receive(:find_or_create_by_profile_id).with(@profile.id).and_return(@pti)
        @pti.should_receive(:profile_text=).with(" apple ")
        @pti.should_receive(:save!)
        
        @matcher.profile_updated(@profile)
      end
    end
    
    describe "deleted" do
      it "should delete assocaited objects" do
        ProfileTextIndex.should_receive(:delete_all).with(['profile_id=?',@profile.id])
        QuestionProfileMatch.should_receive(:delete_all).with(['profile_id=?',@profile.id])
        
        @matcher.profile_deleted(@profile)
      end
    end
    
    it "should get profile keyterms set" do
      @matcher.get_profile_keyterms_set(@profile).should == Set.new
    end
    
    it "should just return for rematch for profile text index" do
      @matcher.rematch_for_profile_text_index(@pti).should == nil
    end
  end # profile
  
  it "should rebuild indices" do
    @matcher.rebuild_indices
  end
  
  it "should run terms analysis" do
    @matcher.run_terms_analysis
  end
  
  describe "top terms" do
    before(:each) do
      @results = []
      
      @mysql_result = mock("mysql_result", :use_result => @results)
      @rawdb = mock("raw_db", :query => @mysql_result, :query_with_result= => false, :close => true)
      @clone = mock("clone", :raw_connection => @rawdb)
      
      ActiveRecord::Base.should_receive(:clone_connection).and_return(@clone)
    end

    it "should not include http:// values as top terms" do      
      @google = ["What is the homepage link for http://www.google.com ?"]
      @mysql_result.stub!(:use_result).and_return([@google])

      @matcher.generate_top_terms

      @terms = TopTerm.find(:all).collect{ |t| t.term }
      @terms.should_not include("google")
      @terms.should include("homepage")
    end
    
    it "should not include even the strangest http:// values" do
      @real_funky = ["What is the deal with funny urls with many parameters like:\r\n\r\nhttp://www.clickmanage.com/events/clickevent.aspx?ca=10204&e=8&l=1046989406&u=http%25253A%25252F%25252Fwww.cruisesonly.com%25252Fresults.do%25253Fplaces%25253DALL%252526Month%25253DALL%252526c%25253D44%252526v%25253D717%252526port%25253D%252526days%25253DALL%252526shoppingZipCode%25253D%252526IncludeSeniorRates%25253Dfalse%252526IncludeAlumniRates%25253Dfalse%252526sort_by%25253D7%252526Search.x%25253D30%252526Search.y%25253D9%252526Search%25253DSearch%252526cid%25253D136KAYOT052620090001ALL%252526utm_source%25253Dyahoo%252526utm_medium%25253Dcpc%252526utm_term%25253Droyal_caribbean_allure_of_the_seas_cruise_line but this one works http://www.clickmanage.com/events/clickevent.aspx?ca=10204&e=8&l=1046989406&u=http%25253A%25252F%25252Fwww.cruisesonly.com%25252Fresults.do%25253Fplaces%25253DALL%252526Month%25253DALL%252526c%25253D44%252526v%25253D717%252526port%25253D%252526days%25253DALL%252526shoppingZipCode%25253D%252526IncludeSeniorRates%25253Dfalse%252526IncludeAlumniRates%25253Dfalse%252526sort_by%25253D7%252526Search.x%25253D30%252526Search.y%25253D9%252526Search%25253DSearch%252526cid%25253D136KAYOT052620090001ALL%252526utm_source%25253Dyahoo%252526utm_medium%25253Dcpc%252526utm_term%25253Droyal_caribbean_allure_of_the_seas_cruise_line. It's very strange."]
      @mysql_result.stub!(:use_result).and_return([@real_funky])

      @matcher.generate_top_terms

      @terms = TopTerm.find(:all).collect{ |t| t.term }      
      @terms.should_not include("252526v")
      @terms.should include("urls")
    end
  end
  
  # describe "statuses" do
  #   describe "search" do
  #     it "should find statuses based on options" do
  #       Status.should_receive(:find).with(:all, :conditions=>["statuses.body LIKE ?", "%query%"])
  #               
  #       @matcher.search_statuses('query', :conditions => "")
  #     end
  #   end
  # end
  
  
end