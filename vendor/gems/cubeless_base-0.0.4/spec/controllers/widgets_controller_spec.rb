require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe WidgetsController do
  before(:each) do
    login_as_content_admin
  end


  def mock_widget(stubs={})
    @mock_widget ||= mock_model(Widget, stubs)
  end
  
  describe "responding to GET index" do

    it "should expose all widgets as @widgets" do
      pending "great 2011 migration"
      Widget.should_receive(:find).with(:all).and_return([mock_widget])
      get :index
      assigns[:widgets].should == [mock_widget]
    end

  end

  describe "responding to GET show" do

    it "should expose the requested widget as @widget" do
      Widget.should_receive(:find).with("37").and_return(mock_widget)
      get :show, :id => "37"
      assigns[:widget].should equal(mock_widget)
    end
    
  end

  describe "responding to GET new" do
  
    it "should expose a new widget as @widget" do
      Widget.should_receive(:new).and_return(mock_widget)
      get :new
      assigns[:widget].should equal(mock_widget)
    end

  end

  describe "responding to GET edit" do
  
    it "should expose the requested widget as @widget" do
      Widget.should_receive(:find).with("37").and_return(mock_widget)
      get :edit, :id => "37"
      assigns[:widget].should equal(mock_widget)
    end

  end

  describe "responding to POST create" do

    describe "with valid params" do
      
      it "should expose a newly created widget as @widget" do
        Widget.should_receive(:new).with({'these' => 'params'}).and_return(mock_widget(:save => true))
        post :create, :widget => {:these => 'params'}
        assigns(:widget).should equal(mock_widget)
      end

      it "should redirect to the widgets list" do
        Widget.stub!(:new).and_return(mock_widget(:save => true))
        post :create, :widget => {}
        response.should redirect_to(widgets_url)
      end
      
    end
    
    describe "with invalid params" do

      it "should expose a newly created but unsaved widget as @widget" do
        Widget.stub!(:new).with({'these' => 'params'}).and_return(mock_widget(:save => false))
        post :create, :widget => {:these => 'params'}
        assigns(:widget).should equal(mock_widget)
      end

      it "should re-render the 'new' template" do
        Widget.stub!(:new).and_return(mock_widget(:save => false))
        post :create, :widget => {}
        response.should render_template('new')
      end
      
    end
    
  end

  describe "responding to PUT udpate" do

    describe "with valid params" do

      it "should update the requested widget" do
        Widget.should_receive(:find).with("37").and_return(mock_widget)
        mock_widget.should_receive(:update_attributes).with({'these' => 'params'})
        put :update, :id => "37", :widget => {:these => 'params'}
      end

      it "should expose the requested widget as @widget" do
        Widget.stub!(:find).and_return(mock_widget(:update_attributes => true))
        put :update, :id => "1"
        assigns(:widget).should equal(mock_widget)
      end

      it "should redirect to the widget" do
        Widget.stub!(:find).and_return(mock_widget(:update_attributes => true))
        put :update, :id => "1"
        response.should redirect_to(widgets_url)
      end

    end
    
    describe "with invalid params" do

      it "should update the requested widget" do
        Widget.should_receive(:find).with("37").and_return(mock_widget)
        mock_widget.should_receive(:update_attributes).with({'these' => 'params'})
        put :update, :id => "37", :widget => {:these => 'params'}
      end

      it "should expose the widget as @widget" do
        Widget.stub!(:find).and_return(mock_widget(:update_attributes => false))
        put :update, :id => "1"
        assigns(:widget).should equal(mock_widget)
      end

      it "should re-render the 'edit' template" do
        Widget.stub!(:find).and_return(mock_widget(:update_attributes => false))
        put :update, :id => "1"
        response.should render_template('edit')
      end

    end

  end

  describe "responding to DELETE destroy" do

    it "should destroy the requested widget" do
      Widget.should_receive(:find).with("37").and_return(mock_widget)
      mock_widget.should_receive(:destroy)
      delete :destroy, :id => "37"
    end
  
    it "should redirect to the widgets list" do
      Widget.stub!(:find).and_return(mock_widget(:destroy => true))
      delete :destroy, :id => "1"
      response.should redirect_to(widgets_url)
    end

  end

end
