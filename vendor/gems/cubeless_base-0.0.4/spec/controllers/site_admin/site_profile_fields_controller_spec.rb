require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe SiteAdmin::SiteProfileFieldsController do
  
  before(:each) do
    pending "great 2011 migration"
    
    login_as_cubeless_admin
  end

  def mock_site_profile_field(stubs={})
    @mock_site_profile_field ||= mock_model(SiteProfileField, stubs)
  end
  
  describe "responding to GET index" do

    it "should expose all site_profile_fields as @site_profile_fields" do
      SiteProfileField.should_receive(:find).with(:all).at_least(1).times.and_return([mock_site_profile_field(:site_biz_card => Object.new, :biz_card_position => 1, :site_profile_page => Object.new, :sticky? => false, :profile_page_position => 1)])
      get :index
      assigns[:site_profile_fields].should == [mock_site_profile_field]
    end

    describe "with mime type of xml" do
  
      # it "should render all site_profile_fields as xml" do
      #   request.env["HTTP_ACCEPT"] = "application/xml"
      #   SiteProfileField.should_receive(:find).with(:all).and_return(site_profile_fields = mock("Array of SiteProfileFields"))
      #   site_profile_fields.should_receive(:to_xml).and_return("generated XML")
      #   get :index
      #   response.body.should == "generated XML"
      # end
    
    end

  end

  describe "responding to GET show" do

    it "should expose the requested site_profile_field as @site_profile_field" do
      SiteProfileField.should_receive(:find).with("37").and_return(mock_site_profile_field)
      get :show, :id => "37"
      assigns[:site_profile_field].should equal(mock_site_profile_field)
    end
    
    describe "with mime type of xml" do

      it "should render the requested site_profile_field as xml" do
        request.env["HTTP_ACCEPT"] = "application/xml"
        SiteProfileField.should_receive(:find).with("37").and_return(mock_site_profile_field)
        mock_site_profile_field.should_receive(:to_xml).and_return("generated XML")
        get :show, :id => "37"
        response.body.should == "generated XML"
      end

    end
    
  end

  describe "responding to GET new" do
  
    it "should expose a new site_profile_field as @site_profile_field" do
      SiteProfileField.should_receive(:new).and_return(mock_site_profile_field(:question= => true))
      get :new
      assigns[:site_profile_field].should equal(mock_site_profile_field)
    end

  end

  describe "responding to GET edit" do
  
    it "should expose the requested site_profile_field as @site_profile_field" do
      SiteProfileField.should_receive(:find).with("37").and_return(mock_site_profile_field)
      get :edit, :id => "37"
      assigns[:site_profile_field].should equal(mock_site_profile_field)
    end

  end

  describe "responding to POST create" do

    describe "with valid params" do
      
      it "should expose a newly created site_profile_field as @site_profile_field" do
        SiteProfileField.should_receive(:new).with({'these' => 'params'}).and_return(mock_site_profile_field(:save => true))
        post :create, :site_profile_field => {:these => 'params'}
        assigns(:site_profile_field).should equal(mock_site_profile_field)
      end

      it "should redirect to the created site_profile_field" do
        SiteProfileField.stub!(:new).and_return(mock_site_profile_field(:save => true))
        post :create, :site_profile_field => {}
        response.should redirect_to(site_admin_site_profile_fields_url)
      end
      
    end
    
    describe "with invalid params" do

      it "should expose a newly created but unsaved site_profile_field as @site_profile_field" do
        SiteProfileField.stub!(:new).with({'these' => 'params'}).and_return(mock_site_profile_field(:save => false))
        post :create, :site_profile_field => {:these => 'params'}
        assigns(:site_profile_field).should equal(mock_site_profile_field)
      end

      it "should re-render the 'new' template" do
        SiteProfileField.stub!(:new).and_return(mock_site_profile_field(:save => false))
        post :create, :site_profile_field => {}
        response.should render_template('new')
      end
      
    end
    
  end

  describe "responding to PUT udpate" do

    describe "with valid params" do

      it "should update the requested site_profile_field" do
        SiteProfileField.should_receive(:find).with("37").and_return(mock_site_profile_field)
        mock_site_profile_field.should_receive(:update_attributes).with({'these' => 'params'})
        put :update, :id => "37", :site_profile_field => {:these => 'params'}
      end

      it "should expose the requested site_profile_field as @site_profile_field" do
        SiteProfileField.stub!(:find).and_return(mock_site_profile_field(:update_attributes => true))
        put :update, :id => "1"
        assigns(:site_profile_field).should equal(mock_site_profile_field)
      end

      it "should redirect to the site_profile_field" do
        SiteProfileField.stub!(:find).and_return(mock_site_profile_field(:update_attributes => true))
        put :update, :id => "1"
        response.should redirect_to(site_admin_site_profile_fields_url)
      end

    end
    
    describe "with invalid params" do

      it "should update the requested site_profile_field" do
        SiteProfileField.should_receive(:find).with("37").and_return(mock_site_profile_field)
        mock_site_profile_field.should_receive(:update_attributes).with({'these' => 'params'})
        put :update, :id => "37", :site_profile_field => {:these => 'params'}
      end

      it "should expose the site_profile_field as @site_profile_field" do
        SiteProfileField.stub!(:find).and_return(mock_site_profile_field(:update_attributes => false))
        put :update, :id => "1"
        assigns(:site_profile_field).should equal(mock_site_profile_field)
      end

      it "should re-render the 'edit' template" do
        SiteProfileField.stub!(:find).and_return(mock_site_profile_field(:update_attributes => false))
        put :update, :id => "1"
        response.should render_template('edit')
      end

    end

  end

  describe "responding to DELETE destroy" do

    it "should destroy the requested site_profile_field" do
      SiteProfileField.should_receive(:find).with("37").and_return(mock_site_profile_field)
      mock_site_profile_field.should_receive(:destroy)
      delete :destroy, :id => "37"
    end
  
    it "should redirect to the site_profile_fields list" do
      SiteProfileField.stub!(:find).and_return(mock_site_profile_field(:destroy => true))
      delete :destroy, :id => "1"
      response.should redirect_to(site_admin_site_profile_fields_url)
    end

  end

end
