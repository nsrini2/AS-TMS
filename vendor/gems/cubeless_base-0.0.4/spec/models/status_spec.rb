require File.dirname(__FILE__) + '/../spec_helper'

describe Status do
  
  before(:each) do
    @valid_attributes = {}
    
    @status = Status.new(@valid_attributes)
  end
  
  it "should create a valid instance" do
    @status.should be_valid
  end
  
  it "should be associated with a profile" do
    @status.should respond_to(:profile)
  end
  
  describe "class methods" do
    it "should search by keywords using the default semantic matcher" do
      options = {}
      
      SemanticMatcher.default.should_receive(:search_statuses).with('query', { :direct_query => true })
      
      Status.find_by_keywords('query', options)
    end
    
    describe "duplicates" do
      before(:each) do
        @status_1 = mock_model(Status) 
        @status_2 = mock_model(Status) 
        @status_3 = mock_model(Status) 
        @status_4 = mock_model(Status) 
        @status_5 = mock_model(Status)
      end  
      
      describe "destroying" do 
        it "should destroy all statuses except the first in the fetched duplicates array" do 
          @duplicates = {"1" => [@status_1, @status_2]}
          Status.stub!(:find_duplicates).and_return(@duplicates)
        
          @status_1.should_not_receive(:destroy)
          @status_2.should_receive(:destroy)
        
          Status.destroy_duplicates
        end  
        
        it "should not delete arrays with only one entry" do 
          @duplicates = {"1" => [@status_1]}
          Status.stub!(:find_duplicates).and_return(@duplicates)
        
          @status_1.should_not_receive(:destroy)
        
          Status.destroy_duplicates
        end
        
        it "should work with arrarys greater than size of 2" do 
          @duplicates = {"1" => [@status_1, @status_2, @status_3], "2" => [@status_4, @status_5] }
          Status.stub!(:find_duplicates).and_return(@duplicates)
        
          @status_1.should_not_receive(:destroy)
          @status_2.should_receive(:destroy)
          @status_3.should_receive(:destroy)
          @status_4.should_not_receive(:destroy)
          @status_5.should_receive(:destroy)
                    
          Status.destroy_duplicates
        end
        
        it "should NOT remove statuses that are more than 24 hours apart" do
          pending "consider adding date to group by at database level if needed - decided not necessary at this time"
        end
      end  
    end  
  end
  
end