require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe SiteAdmin::SiteQuestionCategoriesController do

  before(:each) do
    pending "great 2011 migration"
    login_as_cubeless_admin
  end

  def mock_site_question_category(stubs={})
    stubs = {:name => "Work"}.merge(stubs)
    @mock_site_question_category ||= mock_model(SiteQuestionCategory, stubs)
  end
  
  describe "responding to GET index" do

    it "should expose all site_question_categories as @site_question_categories" do
      SiteQuestionCategory.should_receive(:find).with(:all, {:order=>:position}).and_return([mock_site_question_category])
      get :index
      assigns[:site_question_categories].should == [mock_site_question_category]
    end

    describe "with mime type of xml" do
  
      it "should render all site_question_categories as xml" do
        request.env["HTTP_ACCEPT"] = "application/xml"
        SiteQuestionCategory.should_receive(:find).with(:all, {:order=>:position}).and_return(site_question_categories = mock("Array of SiteQuestionCategories"))
        site_question_categories.should_receive(:to_xml).and_return("generated XML")
        get :index
        response.body.should == "generated XML"
      end
    
    end

  end

  describe "responding to GET show" do

    it "should expose the requested site_question_category as @site_question_category" do
      SiteQuestionCategory.should_receive(:find).with("37").and_return(mock_site_question_category)
      get :show, :id => "37"
      assigns[:site_question_category].should equal(mock_site_question_category)
    end
    
    describe "with mime type of xml" do

      it "should render the requested site_question_category as xml" do
        request.env["HTTP_ACCEPT"] = "application/xml"
        SiteQuestionCategory.should_receive(:find).with("37").and_return(mock_site_question_category)
        mock_site_question_category.should_receive(:to_xml).and_return("generated XML")
        get :show, :id => "37"
        response.body.should == "generated XML"
      end

    end
    
  end

  describe "responding to GET new" do
  
    it "should expose a new site_question_category as @site_question_category" do
      SiteQuestionCategory.should_receive(:new).and_return(mock_site_question_category)
      get :new
      assigns[:site_question_category].should equal(mock_site_question_category)
    end

  end

  describe "responding to GET edit" do
  
    it "should expose the requested site_question_category as @site_question_category" do
      SiteQuestionCategory.should_receive(:find).with("37").and_return(mock_site_question_category)
      get :edit, :id => "37"
      assigns[:site_question_category].should equal(mock_site_question_category)
    end

  end

  describe "responding to POST create" do

    describe "with valid params" do
      
      it "should expose a newly created site_question_category as @site_question_category" do
        SiteQuestionCategory.should_receive(:new).with({'these' => 'params'}).and_return(mock_site_question_category(:save => true))
        post :create, :site_question_category => {:these => 'params'}
        assigns(:site_question_category).should equal(mock_site_question_category)
      end

      it "should redirect to the created site_question_category" do
        SiteQuestionCategory.stub!(:new).and_return(mock_site_question_category(:save => true))
        post :create, :site_question_category => {}
        response.should redirect_to(site_admin_site_question_categories_path)
      end
      
    end
    
    describe "with invalid params" do

      it "should expose a newly created but unsaved site_question_category as @site_question_category" do
        SiteQuestionCategory.stub!(:new).with({'these' => 'params'}).and_return(mock_site_question_category(:save => false))
        post :create, :site_question_category => {:these => 'params'}
        assigns(:site_question_category).should equal(mock_site_question_category)
      end

      it "should re-render the 'new' template" do
        SiteQuestionCategory.stub!(:new).and_return(mock_site_question_category(:save => false))
        post :create, :site_question_category => {}
        response.should render_template('new')
      end
      
    end
    
  end

  describe "responding to PUT udpate" do

    describe "with valid params" do

      it "should update the requested site_question_category" do
        SiteQuestionCategory.should_receive(:find).with("37").and_return(mock_site_question_category)
        mock_site_question_category.should_receive(:update_attributes).with({'these' => 'params'})
        put :update, :id => "37", :site_question_category => {:these => 'params'}
      end

      it "should expose the requested site_question_category as @site_question_category" do
        SiteQuestionCategory.stub!(:find).and_return(mock_site_question_category(:update_attributes => true))
        put :update, :id => "1"
        assigns(:site_question_category).should equal(mock_site_question_category)
      end

      it "should redirect to the site_question_category" do
        SiteQuestionCategory.stub!(:find).and_return(mock_site_question_category(:update_attributes => true))
        put :update, :id => "1"
        response.should redirect_to(site_admin_site_question_categories_path)
      end

    end
    
    describe "with invalid params" do

      it "should update the requested site_question_category" do
        SiteQuestionCategory.should_receive(:find).with("37").and_return(mock_site_question_category)
        mock_site_question_category.should_receive(:update_attributes).with({'these' => 'params'})
        put :update, :id => "37", :site_question_category => {:these => 'params'}
      end

      it "should expose the site_question_category as @site_question_category" do
        SiteQuestionCategory.stub!(:find).and_return(mock_site_question_category(:update_attributes => false))
        put :update, :id => "1"
        assigns(:site_question_category).should equal(mock_site_question_category)
      end

      it "should re-render the 'edit' template" do
        SiteQuestionCategory.stub!(:find).and_return(mock_site_question_category(:update_attributes => false))
        put :update, :id => "1"
        response.should render_template('edit')
      end

    end

  end

  describe "responding to DELETE destroy" do

    it "should destroy the requested site_question_category" do
      SiteQuestionCategory.should_receive(:find).with("37").and_return(mock_site_question_category)
      mock_site_question_category.should_receive(:destroy)
      delete :destroy, :id => "37"
    end
  
    it "should redirect to the site_question_categories list" do
      SiteQuestionCategory.stub!(:find).and_return(mock_site_question_category(:destroy => true))
      delete :destroy, :id => "1"
      response.should redirect_to(site_admin_site_question_categories_path)
    end

  end

end
