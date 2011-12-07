require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe CustomReportsController do
  before(:each) do
    pending "great 2011 migration"
  end

  describe "route recognition" do
    it "should generate params for #index" do
      params_from(:get, "/custom_reports").should == {:controller => "custom_reports", :action => "index"}
    end
  
    it "should generate params for #new" do
      params_from(:get, "/custom_reports/new").should == {:controller => "custom_reports", :action => "new"}
    end
  
    it "should generate params for #create" do
      params_from(:post, "/custom_reports").should == {:controller => "custom_reports", :action => "create"}
    end
  
    it "should generate params for #show" do
      params_from(:get, "/custom_reports/1").should == {:controller => "custom_reports", :action => "show", :id => "1"}
    end
  
    it "should generate params for #edit" do
      params_from(:get, "/custom_reports/1/edit").should == {:controller => "custom_reports", :action => "edit", :id => "1"}
    end
  
    it "should generate params for #update" do
      params_from(:put, "/custom_reports/1").should == {:controller => "custom_reports", :action => "update", :id => "1"}
    end
  
    it "should generate params for #destroy" do
      params_from(:delete, "/custom_reports/1").should == {:controller => "custom_reports", :action => "destroy", :id => "1"}
    end
  end
end
