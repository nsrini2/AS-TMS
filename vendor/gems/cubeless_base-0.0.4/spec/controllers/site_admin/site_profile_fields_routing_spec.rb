require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe SiteAdmin::SiteProfileFieldsController do
  before(:each) do
    pending "great 2011 migration"
  end

  describe "route recognition" do
    it "should generate params for #index" do
      params_from(:get, "/site_admin/site_profile_fields").should == {:controller => "site_admin/site_profile_fields", :action => "index"}
    end
  
    it "should generate params for #new" do
      params_from(:get, "/site_admin/site_profile_fields/new").should == {:controller => "site_admin/site_profile_fields", :action => "new"}
    end
  
    it "should generate params for #create" do
      params_from(:post, "/site_admin/site_profile_fields").should == {:controller => "site_admin/site_profile_fields", :action => "create"}
    end
  
    it "should generate params for #show" do
      params_from(:get, "/site_admin/site_profile_fields/1").should == {:controller => "site_admin/site_profile_fields", :action => "show", :id => "1"}
    end
  
    it "should generate params for #edit" do
      params_from(:get, "/site_admin/site_profile_fields/1/edit").should == {:controller => "site_admin/site_profile_fields", :action => "edit", :id => "1"}
    end
  
    it "should generate params for #update" do
      params_from(:put, "/site_admin/site_profile_fields/1").should == {:controller => "site_admin/site_profile_fields", :action => "update", :id => "1"}
    end
  
    it "should generate params for #destroy" do
      params_from(:delete, "/site_admin/site_profile_fields/1").should == {:controller => "site_admin/site_profile_fields", :action => "destroy", :id => "1"}
    end
  end
end
