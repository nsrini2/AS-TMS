require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe SiteAdmin::SiteProfileQuestionsController do

  before(:each) do
    pending "great 2011 migration"
    login_as_cubeless_admin
  end

  def mock_site_profile_question(stubs={})
    @site_profile_question_section = mock(Object, :site_profile_questions => mock(Object, :count => 1))
    stubs = {:position= => true, :site_profile_question_section => @site_profile_question_section}.merge(stubs)
    
    @mock_site_profile_question ||= mock_model(SiteProfileQuestion, stubs)
  end
  
  describe "responding to GET index" do

    it "should expose all site_profile_questions as @site_profile_questions" do
      SiteProfileQuestion.should_receive(:find).with(:all, {:order=>"site_profile_question_section_id, position"}).and_return([mock_site_profile_question])
      get :index
      assigns[:site_profile_questions].should == [mock_site_profile_question]
    end

    describe "with mime type of xml" do
  
      it "should render all site_profile_questions as xml" do
        request.env["HTTP_ACCEPT"] = "application/xml"
        SiteProfileQuestion.should_receive(:find).with(:all, {:order=>"site_profile_question_section_id, position"}).and_return(site_profile_questions = mock("Array of SiteProfileQuestions"))
        site_profile_questions.should_receive(:to_xml).and_return("generated XML")
        get :index
        response.body.should == "generated XML"
      end
    
    end

  end

  describe "responding to GET show" do

    it "should expose the requested site_profile_question as @site_profile_question" do
      SiteProfileQuestion.should_receive(:find).with("37").and_return(mock_site_profile_question)
      get :show, :id => "37"
      assigns[:site_profile_question].should equal(mock_site_profile_question)
    end
    
    describe "with mime type of xml" do

      it "should render the requested site_profile_question as xml" do
        request.env["HTTP_ACCEPT"] = "application/xml"
        SiteProfileQuestion.should_receive(:find).with("37").and_return(mock_site_profile_question)
        mock_site_profile_question.should_receive(:to_xml).and_return("generated XML")
        get :show, :id => "37"
        response.body.should == "generated XML"
      end

    end
    
  end

  describe "responding to GET new" do
  
    it "should expose a new site_profile_question as @site_profile_question" do
      SiteProfileQuestion.should_receive(:new).and_return(mock_site_profile_question(:question= => true))
      get :new
      assigns[:site_profile_question].should equal(mock_site_profile_question)
    end

  end

  describe "responding to GET edit" do
  
    it "should expose the requested site_profile_question as @site_profile_question" do
      SiteProfileQuestion.should_receive(:find).with("37").and_return(mock_site_profile_question)
      get :edit, :id => "37"
      assigns[:site_profile_question].should equal(mock_site_profile_question)
    end

  end

  describe "responding to POST create" do

    describe "with valid params" do
      
      it "should expose a newly created site_profile_question as @site_profile_question" do
        SiteProfileQuestion.should_receive(:new).with({'these' => 'params'}).and_return(mock_site_profile_question(:save => true))
        post :create, :site_profile_question => {:these => 'params'}
        assigns(:site_profile_question).should equal(mock_site_profile_question)
      end

      it "should redirect to the created site_profile_question" do
        SiteProfileQuestion.stub!(:new).and_return(mock_site_profile_question(:save => true))
        post :create, :site_profile_question => {}
        response.should redirect_to(site_admin_site_profile_questions_url)
      end
      
    end
    
    describe "with invalid params" do

      it "should expose a newly created but unsaved site_profile_question as @site_profile_question" do
        SiteProfileQuestion.stub!(:new).with({'these' => 'params'}).and_return(mock_site_profile_question(:save => false))
        post :create, :site_profile_question => {:these => 'params'}
        assigns(:site_profile_question).should equal(mock_site_profile_question)
      end

      it "should re-render the 'new' template" do
        SiteProfileQuestion.stub!(:new).and_return(mock_site_profile_question(:save => false))
        post :create, :site_profile_question => {}
        response.should render_template('new')
      end
      
    end
    
  end

  describe "responding to PUT udpate" do

    describe "with valid params" do

      it "should update the requested site_profile_question" do
        SiteProfileQuestion.should_receive(:find).with("37").and_return(mock_site_profile_question)
        mock_site_profile_question.should_receive(:update_attributes).with({'these' => 'params'})
        put :update, :id => "37", :site_profile_question => {:these => 'params'}
      end

      it "should expose the requested site_profile_question as @site_profile_question" do
        SiteProfileQuestion.stub!(:find).and_return(mock_site_profile_question(:update_attributes => true))
        put :update, :id => "1"
        assigns(:site_profile_question).should equal(mock_site_profile_question)
      end

      it "should redirect to the site_profile_question" do
        SiteProfileQuestion.stub!(:find).and_return(mock_site_profile_question(:update_attributes => true))
        put :update, :id => "1"
        response.should redirect_to(site_admin_site_profile_questions_url)
      end

    end
    
    describe "with invalid params" do

      it "should update the requested site_profile_question" do
        SiteProfileQuestion.should_receive(:find).with("37").and_return(mock_site_profile_question)
        mock_site_profile_question.should_receive(:update_attributes).with({'these' => 'params'})
        put :update, :id => "37", :site_profile_question => {:these => 'params'}
      end

      it "should expose the site_profile_question as @site_profile_question" do
        SiteProfileQuestion.stub!(:find).and_return(mock_site_profile_question(:update_attributes => false))
        put :update, :id => "1"
        assigns(:site_profile_question).should equal(mock_site_profile_question)
      end

      it "should re-render the 'edit' template" do
        SiteProfileQuestion.stub!(:find).and_return(mock_site_profile_question(:update_attributes => false))
        put :update, :id => "1"
        response.should render_template('edit')
      end

    end

  end

  describe "responding to DELETE destroy" do

    it "should destroy the requested site_profile_question" do
      SiteProfileQuestion.should_receive(:find).with("37").and_return(mock_site_profile_question)
      mock_site_profile_question.should_receive(:destroy)
      delete :destroy, :id => "37"
    end
  
    it "should redirect to the site_profile_questions list" do
      SiteProfileQuestion.stub!(:find).and_return(mock_site_profile_question(:destroy => true))
      delete :destroy, :id => "1"
      response.should redirect_to(site_admin_site_profile_questions_url)
    end

  end

end
