require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe VideosController do
  before(:each) do
    pending "great 2011 migration"
  end
  
  describe "route recognition" do
    it "should generate params for #index" do
      params_from(:get, "/videos").should == {:controller => "videos", :action => "index"}
    end
  
    it "should generate params for #new" do
      params_from(:get, "/videos/new").should == {:controller => "videos", :action => "new"}
    end
  
    it "should generate params for #create" do
      params_from(:post, "/videos").should == {:controller => "videos", :action => "create"}
    end
  
    it "should generate params for #show" do
      params_from(:get, "/videos/1").should == {:controller => "videos", :action => "show", :id => "1"}
    end
  
    it "should generate params for #edit" do
      params_from(:get, "/videos/1/edit").should == {:controller => "videos", :action => "edit", :id => "1"}
    end
  
    it "should generate params for #update" do
      params_from(:put, "/videos/1").should == {:controller => "videos", :action => "update", :id => "1"}
    end
  
    it "should generate params for #destroy" do
      params_from(:delete, "/videos/1").should == {:controller => "videos", :action => "destroy", :id => "1"}
    end
  end
end
