require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe VideosController do
  before(:each) do
    Video.stub!(:enabled?).and_return(true)
    
    login_as_content_admin
  end
  
  def mock_video(stubs={})
    @mock_video ||= mock_model(Video, stubs)
  end
  
  describe "responding to GET index" do

    it "should expose all videos as @videos" do
      Video.should_receive(:find).with(:all).and_return([mock_video])
      get :index
      assigns[:videos].should == [mock_video]
    end

    describe "with mime type of xml" do
  
      it "should render all videos as xml" do
        request.env["HTTP_ACCEPT"] = "application/xml"
        Video.should_receive(:find).with(:all).and_return(videos = mock("Array of Videos"))
        videos.should_receive(:to_xml).and_return("generated XML")
        get :index
        response.body.should == "generated XML"
      end
    
    end

  end

  describe "responding to GET admin" do

    it "should expose the requested video as @video" do
      Video.should_receive(:find).with("37").and_return(mock_video(:encoding_status => "success"))
      get :admin, :id => "37"
      assigns[:video].should equal(mock_video)
    end
    
    # describe "with mime type of xml" do
    # 
    #   it "should render the requested video as xml" do
    #     request.env["HTTP_ACCEPT"] = "application/xml"
    #     Video.should_receive(:find).with("37").and_return(mock_video)
    #     mock_video.should_receive(:to_xml).and_return("generated XML")
    #     get :show, :id => "37"
    #     response.body.should == "generated XML"
    #   end
    # 
    # end
    
  end

  describe "responding to GET show" do
  
    it "should expose the requested video as @video" do
      Video.should_receive(:find).with("37").and_return(mock_video(:encoding_status => "success"))
      get :show, :id => "37"
      assigns[:video].should equal(mock_video)
    end

  end
  
  describe "responding to GET remote" do
    it "should find the requested video as @video" do
      Video.should_receive(:find).with("37").and_return(mock_video)
      
      mock_video.stub!(:private_s3_url).and_return("http://PRIVATE_S3_URL")
      
      get :remote, :id => "37"
      assigns[:video].should equal(mock_video)
    end
    
    it "should redirect to the private s3 url of the video" do
      Video.stub!(:find).and_return(mock_video)
      
      mock_video.should_receive(:private_s3_url).and_return("http://PRIVATE_S3_URL")
      
      get :remote, :id => "37"
      response.should redirect_to("http://PRIVATE_S3_URL")
    end
  end


  describe "responding to GET new" do
  
    it "should expose a new video as @video" do
      Video.should_receive(:new).and_return(mock_video)
      get :new
      assigns[:video].should equal(mock_video)
    end

  end

  describe "responding to GET edit" do
  
    it "should expose the requested video as @video" do
      Video.should_receive(:find).with("37").and_return(mock_video)
      get :edit, :id => "37"
      assigns[:video].should equal(mock_video)
    end

  end

  describe "responding to POST create" do

    describe "with valid params" do
      before(:each) do
        @profile = controller.current_profile
      end
      
      it "should expose a newly created video as @video" do
        Video.should_receive(:new).with({'these' => 'params', 'tag_list' => 'tag1, tag2'}).and_return(mock_video(:save => true, :profile= => @profile))
        post :create, :video => {:these => 'params', :tag_list => 'tag1, tag2'}
        assigns(:video).should equal(mock_video)
      end

      it "should redirect to the created video" do
        Video.stub!(:new).and_return(mock_video(:save => true, :profile= => @profile))
        post :create, :video => {:tag_list => 'tag1, tag2'}
        response.should redirect_to(admin_video_url(mock_video))
      end
      
    end
    
    describe "with invalid params" do

      it "should expose a newly created but unsaved video as @video" do
        Video.stub!(:new).with({'these' => 'params', 'tag_list' => 'tag1, tag2'}).and_return(mock_video(:save => false, :profile= => @profile))
        post :create, :video => {:these => 'params', :tag_list => 'tag1, tag2'}
        assigns(:video).should equal(mock_video)
      end

      it "should re-render the 'new' template" do
        Video.stub!(:new).and_return(mock_video(:save => false, :profile= => @profile))
        post :create, :video => {:tag_list => 'tag1, tag2'}
        response.should render_template('new')
      end
      
    end
    
  end

  describe "responding to PUT udpate" do

    describe "with valid params" do

      it "should update the requested video" do
        Video.should_receive(:find).with("37").and_return(mock_video)
        mock_video.should_receive(:update_attributes).with({'these' => 'params', 'tag_list' => 'tag1, tag2'})
        put :update, :id => "37", :video => {:these => 'params', :tag_list => 'tag1, tag2'}
      end

      it "should expose the requested video as @video" do
        Video.stub!(:find).and_return(mock_video(:update_attributes => true))
        put :update, :id => "1", :video => {:tag_list => 'tag1, tag2'}
        assigns(:video).should equal(mock_video)
      end

      it "should redirect to the video" do
        Video.stub!(:find).and_return(mock_video(:update_attributes => true))
        put :update, :id => "1", :video => {:tag_list => 'tag1, tag2'}
        response.should redirect_to(video_url(mock_video))
      end

    end
    
    describe "with invalid params" do

      it "should update the requested video" do
        Video.should_receive(:find).with("37").and_return(mock_video)
        mock_video.should_receive(:update_attributes).with({'these' => 'params', 'tag_list' => 'tag1, tag2'})
        put :update, :id => "37", :video => {:these => 'params', :tag_list => 'tag1, tag2'}
      end

      it "should expose the video as @video" do
        Video.stub!(:find).and_return(mock_video(:update_attributes => false))
        put :update, :id => "1", :video => {:tag_list => 'tag1, tag2'}
        assigns(:video).should equal(mock_video)
      end

      it "should re-render the 'edit' template" do
        Video.stub!(:find).and_return(mock_video(:update_attributes => false))
        put :update, :id => "1", :video => {:tag_list => 'tag1, tag2'}
        response.should render_template('edit')
      end

    end

  end

  describe "responding to DELETE destroy" do

    it "should destroy the requested video" do
      Video.should_receive(:find).with("37").and_return(mock_video)
      mock_video.should_receive(:destroy)
      delete :destroy, :id => "37"
    end
  
    it "should redirect to the videos list" do
      Video.stub!(:find).and_return(mock_video(:destroy => true))
      delete :destroy, :id => "1"
      response.should redirect_to(videos_url)
    end

  end

end
