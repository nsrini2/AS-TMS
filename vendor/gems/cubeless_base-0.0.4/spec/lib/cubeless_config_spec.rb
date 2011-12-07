require File.dirname(__FILE__) + '/../spec_helper'

describe Config do
  
  describe "load config from db" do
    it "should load the assets if specified" do
      Config.merge!({'last_updated_at' => Time.now})
      
      FileUtils.should_receive(:rm_rf).with(Dir['tmp/cache/[^.]*'])

      @css = CSS.new
      CSS.should_receive(:new).and_return(@css)
      @css.should_receive(:generate)

      Synthesis::AssetPackage.should_receive(:build_all)

      Config.load_config_from_db(:reload_assets => true)
    end
    it "should not load the assets if not specified" do
      FileUtils.should_not_receive(:rm_rf).with(Dir['tmp/cache/[^.]*'])
      CSS.should_not_receive(:new)
      Synthesis::AssetPackage.should_not_receive(:build_all)
      
      Config.load_config_from_db      
    end
    
  end
  
  describe "populate config db" do
    describe "populate site config" do
      before(:each) do
        @site_config = SiteConfig.new
      end
            
      it "should try to find a site_config" do
        SiteConfig.should_receive(:first).and_return(@site_config)
        
        Config.populate_site_config
      end
      
      describe "where one does not already exist" do
        it "should make a new site config object" do
          SiteConfig.delete_all
          
          SiteConfig.should_receive(:new).at_least(1).times.and_return(@site_config)
          
          Config.populate_site_config
        end
        
        it "should save a new site config based off of the current Config" do
          @now = Time.now
          Time.stub!(:now).and_return(@now)
          
          # SiteConfig.should_receive(:create!).with({"registration_queue" => false, 
          #                                           "feedback_email" => "discard@discard.pri", 
          #                                           "email_from_address" => "cubeless ", 
          #                                           "analytics_tracker_code"=>"", 
          #                                           "theme"=>"theme_5", 
          #                                           "rank_enabled"=>false, 
          #                                           "terms_acceptance_required"=>false, 
          #                                           "viewable_karma"=>false, 
          #                                           "disclaimer"=>"*Unauthorized use, copying or printing of pictures and/or information is prohibited.", 
          #                                           "api_enabled"=>false, 
          #                                           "open_registration"=>false, 
          #                                           "site_base_url"=>"http://localhost:3000", 
          #                                           "site_name"=>"cubeless",
          #                                           "updated_at" => @now,
          #                                           "created_at" => @now}).and_return(@site_config)
          
          SiteConfig.should_receive(:create!).and_return(@site_config)
          
          SiteConfig.delete_all
          
          Config.populate_site_config
        end
      end
      
      
    end
  end
  
end