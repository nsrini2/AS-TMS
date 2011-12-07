require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe SiteAdmin::SiteProfileQuestionSectionsController do

  before(:each) do
    pending "great 2011 migration"    
    login_as_cubeless_admin
  end

  def mock_site_profile_question_section(stubs={})
    @mock_site_profile_question_section ||= mock_model(SiteProfileQuestionSection, stubs)
  end
  
  describe "responding to GET index" do

    it "should expose all site_profile_question_sections as @site_profile_question_sections" do
      SiteProfileQuestionSection.should_receive(:find).with(:all, :order => :position).and_return([mock_site_profile_question_section])
      get :index
      assigns[:site_profile_question_sections].should == [mock_site_profile_question_section]
    end

    describe "with mime type of xml" do
  
      it "should render all site_profile_question_sections as xml" do
        request.env["HTTP_ACCEPT"] = "application/xml"
        SiteProfileQuestionSection.should_receive(:find).with(:all, :order => :position).and_return(site_profile_question_sections = mock("Array of SiteProfileQuestionSections"))
        site_profile_question_sections.should_receive(:to_xml).and_return("generated XML")
        get :index
        response.body.should == "generated XML"
      end
    
    end

  end

  describe "responding to GET show" do

    it "should expose the requested site_profile_question_section as @site_profile_question_section" do
      SiteProfileQuestionSection.should_receive(:find).with("37").and_return(mock_site_profile_question_section)
      get :show, :id => "37"
      assigns[:site_profile_question_section].should equal(mock_site_profile_question_section)
    end
    
    describe "with mime type of xml" do

      it "should render the requested site_profile_question_section as xml" do
        request.env["HTTP_ACCEPT"] = "application/xml"
        SiteProfileQuestionSection.should_receive(:find).with("37").and_return(mock_site_profile_question_section)
        mock_site_profile_question_section.should_receive(:to_xml).and_return("generated XML")
        get :show, :id => "37"
        response.body.should == "generated XML"
      end

    end
    
  end

  describe "responding to GET new" do
  
    it "should expose a new site_profile_question_section as @site_profile_question_section" do
      SiteProfileQuestionSection.should_receive(:new).and_return(mock_site_profile_question_section(:position= => true))
      get :new
      assigns[:site_profile_question_section].should equal(mock_site_profile_question_section)
    end

  end

  describe "responding to GET edit" do
  
    it "should expose the requested site_profile_question_section as @site_profile_question_section" do
      SiteProfileQuestionSection.should_receive(:find).with("37").and_return(mock_site_profile_question_section)
      get :edit, :id => "37"
      assigns[:site_profile_question_section].should equal(mock_site_profile_question_section)
    end

  end

  describe "responding to POST create" do

    describe "with valid params" do
      
      it "should expose a newly created site_profile_question_section as @site_profile_question_section" do
        SiteProfileQuestionSection.should_receive(:new).with({'these' => 'params'}).and_return(mock_site_profile_question_section(:save => true))
        post :create, :site_profile_question_section => {:these => 'params'}
        assigns(:site_profile_question_section).should equal(mock_site_profile_question_section)
      end

      it "should redirect to the created site_profile_question_section" do
        SiteProfileQuestionSection.stub!(:new).and_return(mock_site_profile_question_section(:save => true))
        post :create, :site_profile_question_section => {}
        response.should redirect_to(site_admin_site_profile_questions_url)
      end
      
    end
    
    describe "with invalid params" do

      it "should expose a newly created but unsaved site_profile_question_section as @site_profile_question_section" do
        SiteProfileQuestionSection.stub!(:new).with({'these' => 'params'}).and_return(mock_site_profile_question_section(:save => false))
        post :create, :site_profile_question_section => {:these => 'params'}
        assigns(:site_profile_question_section).should equal(mock_site_profile_question_section)
      end

      it "should re-render the 'new' template" do
        SiteProfileQuestionSection.stub!(:new).and_return(mock_site_profile_question_section(:save => false))
        post :create, :site_profile_question_section => {}
        response.should render_template('new')
      end
      
    end
    
  end

  describe "responding to PUT udpate" do

    describe "with valid params" do

      it "should update the requested site_profile_question_section" do
        SiteProfileQuestionSection.should_receive(:find).with("37").and_return(mock_site_profile_question_section)
        mock_site_profile_question_section.should_receive(:update_attributes).with({'these' => 'params'})
        put :update, :id => "37", :site_profile_question_section => {:these => 'params'}
      end

      it "should expose the requested site_profile_question_section as @site_profile_question_section" do
        SiteProfileQuestionSection.stub!(:find).and_return(mock_site_profile_question_section(:update_attributes => true))
        put :update, :id => "1"
        assigns(:site_profile_question_section).should equal(mock_site_profile_question_section)
      end

      it "should redirect to the site_profile_question_section" do
        SiteProfileQuestionSection.stub!(:find).and_return(mock_site_profile_question_section(:update_attributes => true))
        put :update, :id => "1"
        response.should redirect_to(site_admin_site_profile_questions_url)
      end

    end
    
    describe "with invalid params" do

      it "should update the requested site_profile_question_section" do
        SiteProfileQuestionSection.should_receive(:find).with("37").and_return(mock_site_profile_question_section)
        mock_site_profile_question_section.should_receive(:update_attributes).with({'these' => 'params'})
        put :update, :id => "37", :site_profile_question_section => {:these => 'params'}
      end

      it "should expose the site_profile_question_section as @site_profile_question_section" do
        SiteProfileQuestionSection.stub!(:find).and_return(mock_site_profile_question_section(:update_attributes => false))
        put :update, :id => "1"
        assigns(:site_profile_question_section).should equal(mock_site_profile_question_section)
      end

      it "should re-render the 'edit' template" do
        SiteProfileQuestionSection.stub!(:find).and_return(mock_site_profile_question_section(:update_attributes => false))
        put :update, :id => "1"
        response.should render_template('edit')
      end

    end

  end

  describe "responding to DELETE destroy" do

    it "should destroy the requested site_profile_question_section" do
      SiteProfileQuestionSection.should_receive(:find).with("37").and_return(mock_site_profile_question_section)
      mock_site_profile_question_section.should_receive(:destroy)
      delete :destroy, :id => "37"
    end
  
    it "should redirect to the site_profile_question_sections list" do
      SiteProfileQuestionSection.stub!(:find).and_return(mock_site_profile_question_section(:destroy => true))
      delete :destroy, :id => "1"
      response.should redirect_to(site_admin_site_profile_questions_url)
    end

  end

end
