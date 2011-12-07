require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe AdminController do
  describe "as a Cubeless Admin" do
    before(:each) do
      login_as_cubeless_admin
    end
    describe "Accessing the System Environment" do
      it "should get cubleless environment" do
        get :environment
        response.should be_success
      end
      it "should get the request headers" do
        request.should_receive(:headers)
        get :environment
      end
      it "should use reports_stats_sub_menu layout for retrieval of the cubeless environment" do
        # controller.should_receive(:render).with(:layout => 'report_stats_sub_menu' )
        get :environment
      end
    end
  end
  
  describe "as a Report Admin I" do
    before(:each) do
      login_as_report_admin
    end
    it "should see a summary of stats" do
      # controller.should_receive(:render).with(:layout => 'report_stats_sub_menu', :action => 'stats_table')
      get :stats_summary
    end
    it "should see stats by date" do
      # controller.should_receive(:render).with(:layout => 'report_stats_sub_menu')
      get :stats_by_date
    end
    it "should see stats about Profiles" do
      # controller.should_receive(:render).with(:layout => 'report_stats_sub_menu', :action => 'stats_table')
      ReportQueries.stub!(:total_active_profiles => 1)
      get :profiles_summary
    end
    it "should see Top 10 stats" do
      # controller.should_receive(:render).with(:layout => 'report_stats_sub_menu', :action => 'stats_table')
      get :top_10
    end
    it "should not have acess to the environment" do
      get :environment
      response.should be_redirect
    end
  end
  
  describe "as a Content Admin" do
    before(:each) do
      # User.delete_all # get rid of any previously created 'current_user'   

      login_as_content_admin
    end
    
    describe "for Welcome Emails I" do
      before(:each) do
        @email = WelcomeEmail.get
        do_post
      end
      after(:each) do
        @email.reset
      end
      
      def do_preview_post
        post "welcome_email", :welcome_email => {:subject => "hello", :content => "no!"}, :commit => "Preview"
      end
      def do_post
        post "welcome_email", :welcome_email => {:subject => "hello", :content => "no!"}
      end
      def do_reset
        get "reset_welcome_email"
      end
      
      it "should receive a preview email after clicking on 'Preview'" do
        Notifier.should_receive(:deliver_welcome)
        do_preview_post
      end
      
      it "should be able to customize the welcome email" do
        pending "great 2011 migration"
        
        @email.subject.should include("hello")
        @email.content.should include("no")
      end
      
      it "should be able to reset the welcome email back to the default subject and content" do
        do_reset
        @email.subject.should include("Welcome to")
        @email.content.should include("community")
      end
    end
  end
  
  describe "as a Shady Admin I" do
    before(:each) do
      login_as_shady_admin
    end
    it "should be able to see a listing of items marked as Shady" do
      pending "great 2011 migration"
      
      abuse = mock_model(Abuse)
      Abuse.stub!(:find => [abuse])
      # controller.should_receive(:render).with(:partial => 'admin/shady_template', :locals => {:flagged => [abuse], :hide => {:search => true}}, :layout => 'shady_admin_sub_menu')
      get :shady_admin
    end
    it "should be able to see the history of items marked as Shady" do
      # controller.should_receive(:render).with(:layout => 'shady_admin_sub_menu')
      get :shady_history
    end
  end
  
  describe "as an Awards Admin I" do
    before(:each) do
      login_as_awards_admin
    end
    it "should be able to see all active awards" do
      # controller.should_receive(:render).with(:template => 'awards/awards', :layout => 'awards_sub_menu')
      get :current_awards
    end
    it "should be able to see all archived awards" do
      # controller.should_receive(:render).with(:template => 'awards/awards', :layout => 'awards_sub_menu')
      get :awards_archive
    end
  end

end
