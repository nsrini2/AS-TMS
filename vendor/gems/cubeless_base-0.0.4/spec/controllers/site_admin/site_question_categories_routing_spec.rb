require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe SiteAdmin::SiteQuestionCategoriesController do
  before(:each) do
    pending "great 2011 migration"
  end

  describe "route recognition" do
    it "should generate params for #index" do
      params_from(:get, "/site_admin/site_question_categories").should == {:controller => "site_admin/site_question_categories", :action => "index"}
    end
  
    it "should generate params for #new" do
      params_from(:get, "/site_admin/site_question_categories/new").should == {:controller => "site_admin/site_question_categories", :action => "new"}
    end
  
    it "should generate params for #create" do
      params_from(:post, "/site_admin/site_question_categories").should == {:controller => "site_admin/site_question_categories", :action => "create"}
    end
  
    it "should generate params for #show" do
      params_from(:get, "/site_admin/site_question_categories/1").should == {:controller => "site_admin/site_question_categories", :action => "show", :id => "1"}
    end
  
    it "should generate params for #edit" do
      params_from(:get, "/site_admin/site_question_categories/1/edit").should == {:controller => "site_admin/site_question_categories", :action => "edit", :id => "1"}
    end
  
    it "should generate params for #update" do
      params_from(:put, "/site_admin/site_question_categories/1").should == {:controller => "site_admin/site_question_categories", :action => "update", :id => "1"}
    end
  
    it "should generate params for #destroy" do
      params_from(:delete, "/site_admin/site_question_categories/1").should == {:controller => "site_admin/site_question_categories", :action => "destroy", :id => "1"}
    end
  end
end
