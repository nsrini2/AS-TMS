require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe SiteAdminController do

  before(:each) do
    pending "great 2011 migration"

    login_as_cubeless_admin
    
    @config = mock_model(SiteConfig)
  end


  describe "GET 'index'" do
    it "should be successful" do
      get 'index'
      response.should be_success
    end
  end
  
  describe "GET 'general'" do
    it "should get the site " do
      SiteConfig.should_receive(:first).and_return(@config)
      
      get 'general'
    end
    it "should be successful" do
      get 'general'
      response.should be_success
    end
  end
  
  describe "POST 'publish_general'" do
    before(:each) do
      SiteConfig.stub!(:first).and_return(@config)
      @config.stub!(:update_attributes).and_return(true)
    end

    def do_post
      post 'publish_general'
    end    
    
    it "should update the general settings of the site config" do      
      SiteConfig.should_receive(:first).and_return(@config)
      @config.should_receive(:update_attributes).and_return(true)      
      
      do_post
    end
    
    describe "success" do
      before(:each) do
        @config.should_receive(:update_attributes).and_return(true)        
      end
      
      it "should redirect to 'general'" do
        do_post
        response.should redirect_to(general_site_admin_url)
      end
      it "should give a success notice" do
        do_post
        flash[:notice].should == "Success"
      end
    end
    
    describe "failure" do
      before(:each) do
        @config.should_receive(:update_attributes).and_return(false)        
      end
            
      it "should redirect to 'general'" do
        do_post
        response.should redirect_to(general_site_admin_url)
      end
      it "should give an error notice" do
        do_post
        flash[:errors].should == "Error"
      end
    end
    

  end
end
