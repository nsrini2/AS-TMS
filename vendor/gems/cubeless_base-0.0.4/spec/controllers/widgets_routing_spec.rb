require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe WidgetsController do
  before(:each) do
    pending "great 2011 migration"
  end

  describe "route recognition" do
    it "should generate params for #index" do
      params_from(:get, "/admin/widgets").should == {:controller => "widgets", :action => "index"}
    end
  
    it "should generate params for #new" do
      params_from(:get, "/admin/widgets/new").should == {:controller => "widgets", :action => "new"}
    end
  
    it "should generate params for #create" do
      params_from(:post, "/admin/widgets").should == {:controller => "widgets", :action => "create"}
    end
  
    it "should generate params for #show" do
      params_from(:get, "/admin/widgets/1").should == {:controller => "widgets", :action => "show", :id => "1"}
    end
  
    it "should generate params for #edit" do
      params_from(:get, "/admin/widgets/1/edit").should == {:controller => "widgets", :action => "edit", :id => "1"}
    end
  
    it "should generate params for #update" do
      params_from(:put, "/admin/widgets/1").should == {:controller => "widgets", :action => "update", :id => "1"}
    end
  
    it "should generate params for #destroy" do
      params_from(:delete, "/admin/widgets/1").should == {:controller => "widgets", :action => "destroy", :id => "1"}
    end
  end
end
