require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
  # SSJ -- I am testing this on the modules on which it is included...  
  # Should only have to test this once, then test that it gets included ok, but
  # I am concerned about compatible arguments etc., so I am testing the objects that use it
   
describe Streamed do
  # COMPANY STREAM
  describe Question do
    before(:each) do
      @company_question = Factory.build(:question, :company_id => 1)  
    end

    it "should have an add_to_company_stream method" do
      @company_question.public_methods.include?('add_to_company_stream').should be_true
      @company_question.should_receive(:add_to_company_stream).and_return(:true)
      @company_question.add_to_company_stream 
    end
  
    it "should add to company stream if it is a company question and has a profile_id" do
      @company_question.stub!(:company?).and_return(true)
      CompanyStreamEvent.should_receive(:add).and_return(true)
      @company_question.add_to_company_stream
    end
  
    it "should NOT add to company stream if it is NOT a company question" do
      @company_question.stub!(:company?).and_return(false)
      CompanyStreamEvent.should_not_receive(:add).and_return(true)
      @company_question.add_to_company_stream
    end 
  
    it "should NOT add to company stream if it does NOT has a profile_id" do
      @company_question.stub!(:company?).and_return(true)
      @company_question.stub!(:profile_id).and_return(nil)
      CompanyStreamEvent.should_not_receive(:add).and_return(true)
      @company_question.add_to_company_stream
    end
  
    it "should have a remove_from_company_stream method" do
      @company_question.should_receive(:remove_from_company_stream).and_return(:true)
      @company_question.remove_from_company_stream
    end
  
    it "should be removed from CompanyStreamEvent if it is deleted" do
      @company_question.stub!(:company?).and_return(true)
      @event = mock_model(CompanyStreamEvent)
      @events = [@event]
      @events.stub!(:where).and_return(@events)
      CompanyStreamEvent.stub!(:where).and_return(@events)
      # CompanyStreamEvent.should_receive(:where).exactly(2).times.and_return(CompanyStreamEvent)
      # CompanyStreamEvent.stub!(:find).and_return(@events)
      @event.should_receive(:destroy).and_return(true)
    
      @company_question.remove_from_company_stream
    end
  end
  describe Answer do
    before(:each) do
      @company_question = Factory.build(:question, :company_id => 1)  
      @company_answer =  Factory.build(:answer) 
      @company_answer.stub!(:question).and_return(@company_question)
    end

    it "should have an add_to_company_stream method" do
      @company_answer.should_receive(:add_to_company_stream).and_return(:true)
      @company_answer.add_to_company_stream 
    end
  
    it "should add to company stream if it is a company answer and has a profile_id" do
      CompanyStreamEvent.should_receive(:add).and_return(true)
      @company_answer.add_to_company_stream
    end
  
    it "should NOT add to company stream if it is NOT a company question" do
      @company_answer.stub!(:company?).and_return(false)
      CompanyStreamEvent.should_not_receive(:add).and_return(true)
      @company_answer.add_to_company_stream
    end 
  
    it "should NOT add to company stream if it does NOT has a profile_id" do
      @company_answer.stub!(:company?).and_return(true)
      @company_answer.stub!(:profile_id).and_return(nil)
      CompanyStreamEvent.should_not_receive(:add).and_return(true)
      @company_answer.add_to_company_stream
    end
  
    it "should have a remove_from_company_stream method" do
      @company_answer.should_receive(:remove_from_company_stream).and_return(:true)
      @company_answer.remove_from_company_stream
    end
  
    it "should be removed from CompanyStreamEvent if it is deleted " do
      @company_answer.stub!(:company?).and_return(true)
    
      @event = mock_model(CompanyStreamEvent)
      @events = [@event]
    
      @events.stub!(:where).and_return(@events)
      CompanyStreamEvent.stub!(:where).and_return(@events)
    
      # CompanyStreamEvent.should_receive(:where).exactly(2).times.and_return(CompanyStreamEvent)
      # CompanyStreamEvent.stub!(:find).and_return(@events)
    
      @event.should_receive(:destroy).and_return(true)
      @company_answer.remove_from_company_stream
    end
  end  
  describe BlogPost do
    before(:each) do
      @company = Factory.build(:company)
      @blog = Factory.build(:blog)
      @company_blog_post = Factory.build(:blog_post)  
      @blog.owner = @company
      @company_blog_post.blog = @blog
    end

    it "should have an add_to_company_stream method" do
      @company_blog_post.should_receive(:add_to_company_stream).and_return(:true)
      @company_blog_post.add_to_company_stream 
    end
  
    it "should add to company stream if it is a company answer and has a profile_id" do
      CompanyStreamEvent.should_receive(:add).and_return(true)
      @company_blog_post.add_to_company_stream
    end
  
    it "should NOT add to company stream if it is NOT a company question" do
      @company_blog_post.stub!(:company?).and_return(false)
      CompanyStreamEvent.should_not_receive(:add).and_return(true)
      @company_blog_post.add_to_company_stream
    end 
  
    it "should NOT add to company stream if it does NOT has a profile_id" do
      @company_blog_post.stub!(:company?).and_return(true)
      @company_blog_post.stub!(:profile_id).and_return(nil)
      CompanyStreamEvent.should_not_receive(:add).and_return(true)
      @company_blog_post.add_to_company_stream
    end
  
    it "should have a remove_from_company_stream method" do
      @company_blog_post.should_receive(:remove_from_company_stream).and_return(:true)
      @company_blog_post.remove_from_company_stream
    end
     
    it "should be removed from CompanyStreamEvent if it is deleted " do
      @company_blog_post.stub!(:company?).and_return(true)
  
      @event = mock_model(CompanyStreamEvent)
      @events = [@event]
  
      @events.stub!(:where).and_return(@events)
      CompanyStreamEvent.stub!(:where).and_return(@events)
  
      # CompanyStreamEvent.should_receive(:where).exactly(2).times.and_return(CompanyStreamEvent)
      # CompanyStreamEvent.stub!(:find).and_return(@events)
  
      @event.should_receive(:destroy).and_return(true)
      @company_blog_post.remove_from_company_stream
    end
  end
  describe Comment do
    before(:each) do
      @company = Factory.build(:company)
      @blog = Factory.build(:blog)
      @company_blog_post = Factory.build(:blog_post)  
      @blog.owner = @company
      @company_blog_post.blog = @blog
      @company_comment = Factory.build(:comment)
      @company_comment.owner = @company_blog_post
    end

    it "should have an add_to_company_stream method" do
      @company_comment.should_receive(:add_to_company_stream).and_return(:true)
      @company_comment.add_to_company_stream 
    end
  
    it "should add to company stream if it is a company comment and has a profile_id" do
      CompanyStreamEvent.should_receive(:add).and_return(true)
      @company_comment.add_to_company_stream
    end
  
    it "should NOT add to company stream if it is NOT a company question" do
      @company_comment.stub!(:company?).and_return(false)
      CompanyStreamEvent.should_not_receive(:add).and_return(true)
      @company_comment.add_to_company_stream
    end 
  
    it "should NOT add to company stream if it does NOT has a profile_id" do
      @company_comment.stub!(:company?).and_return(true)
      @company_comment.stub!(:profile_id).and_return(nil)
      CompanyStreamEvent.should_not_receive(:add).and_return(true)
      @company_comment.add_to_company_stream
    end
  
    it "should have a remove_from_company_stream method" do
      @company_comment.should_receive(:remove_from_company_stream).and_return(:true)
      @company_comment.remove_from_company_stream
    end
     
    it "should be removed from CompanyStreamEvent if it is deleted " do
      @company_comment.stub!(:company?).and_return(true)
  
      @event = mock_model(CompanyStreamEvent)
      @events = [@event]
  
      @events.stub!(:where).and_return(@events)
      CompanyStreamEvent.stub!(:where).and_return(@events)
  
      # CompanyStreamEvent.should_receive(:where).exactly(2).times.and_return(CompanyStreamEvent)
      # CompanyStreamEvent.stub!(:find).and_return(@events)
  
      @event.should_receive(:destroy).and_return(true)
      @company_comment.remove_from_company_stream
    end
  end

  # ACTIVITY STREAM  
  describe Question do
    before(:each) do
      @question = Factory.build(:question)  
    end

    it "should have an add_to_activity_stream method" do
      @question.public_methods.include?('add_to_activity_stream').should be_true
      @question.should_receive(:add_to_activity_stream).and_return(:true)
      @question.add_to_activity_stream 
    end
    
    it "should add to activity stream unless it is a private question and has a profile_id" do
      @question.stub!(:company?).and_return(false)
      @question.stub!(:private?).and_return(false)
      ActivityStreamEvent.should_receive(:add).and_return(true)
      @question.add_to_activity_stream
    end
    
    it "should NOT add to activity stream if it is a COMPNAY question" do
      @company.stub!(:company?).and_return(true)
      ActivityStreamEvent.should_not_receive(:add).and_return(true)
      @question.add_to_company_stream
    end 
  
    it "should NOT add to activity stream if it is PRIVATE?" do
      @question.stub!(:company?).and_return(false)
      @question.stub!(:private?).and_return(true)
      @question.send(:skip_logging?).should be_true
      ActivityStreamEvent.should_not_receive(:add).and_return(true)
      @question.add_to_activity_stream
    end
    
    it "should have a remove_from_activity_stream method" do
      @question.public_methods.include?('remove_from_activity_stream').should be_true
      @question.should_receive(:remove_from_activity_stream).and_return(:true)
      @question.remove_from_activity_stream
    end
    
    it "should be removed from ActivityStreamEvent if it is deleted" do
      @question.stub!(:company?).and_return(false)
      @question.stub!(:private?).and_return(false)
      @event = mock_model(ActivityStreamEvent)
      @events = [@event]
      @events.stub!(:where).and_return(@events)
      ActivityStreamEvent.stub!(:where).and_return(@events)
      @event.should_receive(:destroy).and_return(true)
    
      @question.remove_from_activity_stream
    end
    
  end
  
  describe Answer do
    before(:each) do
      @question = Factory.build(:question)  
      @answer =  Factory.build(:answer) 
      @answer.stub!(:question).and_return(@question) 
    end

    it "should have an add_to_activity_stream method" do
      @answer.public_methods.include?('add_to_activity_stream').should be_true
      @answer.should_receive(:add_to_activity_stream).and_return(:true)
      @answer.add_to_activity_stream 
    end
    
    it "should add to activity stream unless it is a private question and has a profile_id" do
      @answer.stub!(:company?).and_return(false)
      @answer.stub!(:private?).and_return(false)
      ActivityStreamEvent.should_receive(:add).and_return(true)
      @answer.add_to_activity_stream
    end
    
    it "should NOT add to activity stream if it is a COMPNAY question" do
      @answer.stub!(:company?).and_return(true)
      ActivityStreamEvent.should_not_receive(:add).and_return(true)
      @answer.add_to_company_stream
    end 
  
    it "should NOT add to activity stream if it is PRIVATE?" do
      @answer.stub!(:company?).and_return(false)
      @answer.stub!(:private?).and_return(true)
      @answer.send(:skip_logging?).should be_true
      ActivityStreamEvent.should_not_receive(:add).and_return(true)
      @answer.add_to_activity_stream
    end
    
    it "should have a remove_from_activity_stream method" do
      @answer.public_methods.include?('remove_from_activity_stream').should be_true
      @answer.should_receive(:remove_from_activity_stream).and_return(:true)
      @answer.remove_from_activity_stream
    end
    
    it "should be removed from ActivityStreamEvent if it is deleted" do
      @answer.stub!(:company?).and_return(false)
      @answer.stub!(:private?).and_return(false)
      @event = mock_model(ActivityStreamEvent)
      @events = [@event]
      @events.stub!(:where).and_return(@events)
      ActivityStreamEvent.stub!(:where).and_return(@events)
      @event.should_receive(:destroy).and_return(true)
    
      @answer.remove_from_activity_stream
    end
    
  end


end