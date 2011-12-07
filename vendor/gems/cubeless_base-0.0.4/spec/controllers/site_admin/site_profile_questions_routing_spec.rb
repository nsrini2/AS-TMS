require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe SiteAdmin::SiteProfileQuestionsController do
  before(:each) do
    pending "great 2011 migration"
  end

  describe "route recognition" do
    it "should generate params for #index" do
      params_from(:get, "/site_admin/site_profile_questions").should == {:controller => "site_admin/site_profile_questions", :action => "index"}
    end
  
    it "should generate params for #new" do
      params_from(:get, "/site_admin/site_profile_questions/new").should == {:controller => "site_admin/site_profile_questions", :action => "new"}
    end
  
    it "should generate params for #create" do
      params_from(:post, "/site_admin/site_profile_questions").should == {:controller => "site_admin/site_profile_questions", :action => "create"}
    end
  
    it "should generate params for #show" do
      params_from(:get, "/site_admin/site_profile_questions/1").should == {:controller => "site_admin/site_profile_questions", :action => "show", :id => "1"}
    end
  
    it "should generate params for #edit" do
      params_from(:get, "/site_admin/site_profile_questions/1/edit").should == {:controller => "site_admin/site_profile_questions", :action => "edit", :id => "1"}
    end
  
    it "should generate params for #update" do
      params_from(:put, "/site_admin/site_profile_questions/1").should == {:controller => "site_admin/site_profile_questions", :action => "update", :id => "1"}
    end
  
    it "should generate params for #destroy" do
      params_from(:delete, "/site_admin/site_profile_questions/1").should == {:controller => "site_admin/site_profile_questions", :action => "destroy", :id => "1"}
    end
  end
end
