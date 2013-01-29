require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe SiteAdmin::SiteRegistrationFieldsController do

  def mock_site_registration_field(stubs={})
    stubs = {:name => "Work", "label" => "Work", :required => false, :options => "", :update_attributes => true, :save => true}.merge(stubs)
    @mock_site_registration_field ||= mock_model(SiteRegistrationField, stubs)
  end

  before(:each) do
    login_as_cubeless_admin
    
    SiteRegistrationField.stub!(:find).with(:all, {:order=>:position}).and_return([mock_site_registration_field])
  end
  
  describe "responding to GET index" do

    it "should expose all site_registration_fields as @site_registration_fields" do
      SiteRegistrationField.should_receive(:find).with(:all, {:order=>:position}).and_return([mock_site_registration_field])
      get :index
      assigns[:site_registration_fields].should == [mock_site_registration_field]
    end

    # describe "with mime type of xml" do
    #   
    #   it "should render all site_registration_fields as xml" do
    #     request.env["HTTP_ACCEPT"] = "application/xml"
    #     
    #     site_registration_fields = [mock_site_registration_field]
    #     SiteRegistrationField.should_receive(:find).with(:all, {:order=>:position}).and_return(site_registration_fields)
    #     site_registration_fields.should_receive(:to_xml).and_return("generated XML")
    #     get :index
    #     response.body.should == "generated XML"
    #   end
    # 
    # end

  end

  describe "responding to GET show" do

    it "should expose the requested site_registration_field as @site_registration_field" do
      SiteRegistrationField.should_receive(:find).with("37").and_return(mock_site_registration_field)
      get :show, :id => "37"
      assigns[:site_registration_field].should equal(mock_site_registration_field)
    end
    
    describe "with mime type of xml" do

      it "should render the requested site_registration_field as xml" do
        request.env["HTTP_ACCEPT"] = "application/xml"
        SiteRegistrationField.should_receive(:find).with("37").and_return(mock_site_registration_field)
        mock_site_registration_field.should_receive(:to_xml).and_return("generated XML")
        get :show, :id => "37"
        response.body.should == "generated XML"
      end

    end
    
  end

  describe "responding to GET new" do
  
    it "should expose a new site_registration_field as @site_registration_field" do
      SiteRegistrationField.should_receive(:new).and_return(mock_site_registration_field)
      get :new
      assigns[:site_registration_field].should equal(mock_site_registration_field)
    end

  end

  describe "responding to GET edit" do
  
    it "should expose the requested site_registration_field as @site_registration_field" do
      SiteRegistrationField.should_receive(:find).with("37").and_return(mock_site_registration_field)
      get :edit, :id => "37"
      assigns[:site_registration_field].should equal(mock_site_registration_field)
    end

  end

  describe "responding to POST create" do

    describe "with valid params" do
      
      it "should expose a newly created site_registration_field as @site_registration_field" do
        SiteRegistrationField.should_receive(:new).with({'these' => 'params'}).and_return(mock_site_registration_field(:save => true))
        post :create, :site_registration_field => {:these => 'params'}
        assigns(:site_registration_field).should equal(mock_site_registration_field)
      end

      it "should redirect to the created site_registration_field" do
        SiteRegistrationField.stub!(:new).and_return(mock_site_registration_field(:save => true))
        post :create, :site_registration_field => {}
        response.should redirect_to(site_admin_site_registration_fields_path)
      end
      
    end
    
    describe "with invalid params" do

      it "should expose a newly created but unsaved site_registration_field as @site_registration_field" do
        SiteRegistrationField.stub!(:new).with({'these' => 'params'}).and_return(mock_site_registration_field(:save => false))
        
        @mock_site_registration_field.stub!(:update_attributes).and_return(false)
        
        post :create, :site_registration_field => {:these => 'params'}
        assigns(:site_registration_field).should equal(mock_site_registration_field)
      end

      it "should re-render the 'new' template" do
        SiteRegistrationField.stub!(:new).and_return(mock_site_registration_field(:save => false))
        
        @mock_site_registration_field.stub!(:save).and_return(false)
        
        post :create, :site_registration_field => {}
        response.should render_template('new')
      end
      
    end
    
  end

  describe "responding to PUT udpate" do

    describe "with valid params" do

      it "should update the requested site_registration_field" do
        SiteRegistrationField.should_receive(:find).with("37").and_return(mock_site_registration_field)
        mock_site_registration_field.should_receive(:update_attributes).with({'these' => 'params'})
        put :update, :id => "37", :site_registration_field => {:these => 'params'}
      end

      it "should expose the requested site_registration_field as @site_registration_field" do
        SiteRegistrationField.stub!(:find).with("1").and_return(mock_site_registration_field(:update_attributes => true))
        put :update, :id => "1"
        assigns(:site_registration_field).should equal(mock_site_registration_field)
      end

      it "should redirect to the site_registration_field" do
        SiteRegistrationField.stub!(:find).with("1").and_return(mock_site_registration_field(:update_attributes => true))
        put :update, :id => "1"
        response.should redirect_to(site_admin_site_registration_fields_path)
      end

    end
    
    describe "with invalid params" do

      it "should update the requested site_registration_field" do
        SiteRegistrationField.should_receive(:find).with("37").and_return(mock_site_registration_field)
        mock_site_registration_field.should_receive(:update_attributes).with({'these' => 'params'})
        put :update, :id => "37", :site_registration_field => {:these => 'params'}
      end

      it "should expose the site_registration_field as @site_registration_field" do
        SiteRegistrationField.stub!(:find).with("1").and_return(mock_site_registration_field(:update_attributes => false))
        put :update, :id => "1"
        assigns(:site_registration_field).should equal(mock_site_registration_field)
      end

      it "should re-render the 'edit' template" do
        SiteRegistrationField.stub!(:find).with("1").and_return(mock_site_registration_field(:update_attributes => false))
        
        @mock_site_registration_field.stub!(:update_attributes).and_return(false)
        
        put :update, :id => "1"
        response.should render_template('edit')
      end

    end

  end

  describe "responding to DELETE destroy" do

    it "should destroy the requested site_registration_field" do
      SiteRegistrationField.should_receive(:find).with("37").and_return(mock_site_registration_field)
      mock_site_registration_field.should_receive(:destroy)
      delete :destroy, :id => "37"
    end
  
    it "should redirect to the site_registration_fields list" do
      #SiteRegistrationField.should_receive(:find).with("1").and_return(mock_site_registration_field(:destroy => true))
      SiteRegistrationField.stub!(:find).with("1").and_return(mock_site_registration_field(:destroy => true))
      delete :destroy, :id => "1"
      response.should redirect_to(site_admin_site_registration_fields_path)
    end

  end

end
