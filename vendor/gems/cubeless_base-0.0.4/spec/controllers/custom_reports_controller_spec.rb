require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe CustomReportsController do
  before(:each) do
    pending "great 2011 migration"
    login_as_report_admin
  end


  def mock_custom_report(stubs={:form => "klass=Group"})
    @mock_custom_report ||= mock_model(CustomReport, stubs)
  end
  
  describe "responding to GET index" do

    it "should expose all custom_reports as @custom_reports" do
      CustomReport.should_receive(:find).with(:all).and_return([mock_custom_report])
      get :index
      assigns[:custom_reports].should == [mock_custom_report]
    end

    describe "with mime type of xml" do
  
      it "should render all custom_reports as xml" do
        request.env["HTTP_ACCEPT"] = "application/xml"
        CustomReport.should_receive(:find).with(:all).and_return(custom_reports = mock("Array of CustomReports"))
        custom_reports.should_receive(:to_xml).and_return("generated XML")
        get :index
        response.body.should == "generated XML"
      end
    
    end

  end

  describe "responding to GET show" do

    it "should expose the requested custom_report as @custom_report" do
      CustomReport.should_receive(:find).with("37").and_return(mock_custom_report)
      get :show, :id => "37"
      assigns[:custom_report].should equal(mock_custom_report)
    end
    
    describe "with mime type of xml" do

      it "should render the requested custom_report as xml" do
        request.env["HTTP_ACCEPT"] = "application/xml"
        CustomReport.should_receive(:find).with("37").and_return(mock_custom_report)
        mock_custom_report.should_receive(:to_xml).and_return("generated XML")
        get :show, :id => "37"
        response.body.should == "generated XML"
      end

    end
    
  end

  describe "responding to GET new" do
  
    it "should expose a new custom_report as @custom_report" do
      CustomReport.should_receive(:new).and_return(mock_custom_report)
      get :new
      assigns[:custom_report].should equal(mock_custom_report)
    end

  end

  describe "responding to GET edit" do
  
    it "should expose the requested custom_report as @custom_report" do
      CustomReport.should_receive(:find).with("37").and_return(mock_custom_report)
      get :edit, :id => "37"
      assigns[:custom_report].should equal(mock_custom_report)
    end

  end

  describe "responding to POST create" do

    describe "with valid params" do
      
      it "should expose a newly created custom_report as @custom_report" do
        CustomReport.should_receive(:new).with({'these' => 'params'}).and_return(mock_custom_report(:save => true))
        post :create, :custom_report => {:these => 'params'}
        assigns(:custom_report).should equal(mock_custom_report)
      end

      it "should redirect to the created custom_report" do
        CustomReport.stub!(:new).and_return(mock_custom_report(:save => true))
        post :create, :custom_report => {}
        response.should redirect_to(custom_report_url(mock_custom_report))
      end
      
    end
    
    describe "with invalid params" do

      it "should expose a newly created but unsaved custom_report as @custom_report" do
        CustomReport.stub!(:new).with({'these' => 'params'}).and_return(mock_custom_report(:save => false))
        post :create, :custom_report => {:these => 'params'}
        assigns(:custom_report).should equal(mock_custom_report)
      end

      it "should re-render the 'new' template" do
        CustomReport.stub!(:new).and_return(mock_custom_report(:save => false))
        post :create, :custom_report => {}
        response.should render_template('new')
      end
      
    end
    
  end

  describe "responding to PUT udpate" do

    describe "with valid params" do

      it "should update the requested custom_report" do
        CustomReport.should_receive(:find).with("37").and_return(mock_custom_report)
        mock_custom_report.should_receive(:update_attributes).with({'these' => 'params'})
        put :update, :id => "37", :custom_report => {:these => 'params'}
      end

      it "should expose the requested custom_report as @custom_report" do
        CustomReport.stub!(:find).and_return(mock_custom_report(:update_attributes => true))
        put :update, :id => "1"
        assigns(:custom_report).should equal(mock_custom_report)
      end

      it "should redirect to the custom_report" do
        CustomReport.stub!(:find).and_return(mock_custom_report(:update_attributes => true))
        put :update, :id => "1"
        response.should redirect_to(custom_report_url(mock_custom_report))
      end

    end
    
    describe "with invalid params" do

      it "should update the requested custom_report" do
        CustomReport.should_receive(:find).with("37").and_return(mock_custom_report)
        mock_custom_report.should_receive(:update_attributes).with({'these' => 'params'})
        put :update, :id => "37", :custom_report => {:these => 'params'}
      end

      it "should expose the custom_report as @custom_report" do
        CustomReport.stub!(:find).and_return(mock_custom_report(:update_attributes => false))
        put :update, :id => "1"
        assigns(:custom_report).should equal(mock_custom_report)
      end

      it "should re-render the 'edit' template" do
        CustomReport.stub!(:find).and_return(mock_custom_report(:update_attributes => false))
        put :update, :id => "1"
        response.should render_template('edit')
      end

    end

  end

  describe "responding to DELETE destroy" do

    it "should destroy the requested custom_report" do
      CustomReport.should_receive(:find).with("37").and_return(mock_custom_report)
      mock_custom_report.should_receive(:destroy)
      delete :destroy, :id => "37"
    end
  
    it "should redirect to the custom_reports list" do
      CustomReport.stub!(:find).and_return(mock_custom_report(:destroy => true))
      delete :destroy, :id => "1"
      response.should redirect_to(custom_reports_url)
    end

  end

end
