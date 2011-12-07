require File.dirname(__FILE__) + '/../spec_helper'

describe ApplicationHelper do  

  before(:each) do
    @profile = mock_model(Profile, :screen_name => "Mark McSpadden", :name => "Mark McSpadden", :karma_points => 5)
    helper.stub!(:current_profile).and_return(@profile)
  end
  
  it "should get the submenu for a list" do
    helper.sub_menu_for(["hi", "bye"]).should == "<ul class=\"action_list sub_nav \">hibye</ul>"
  end
  
  it "should get a submenu li for a link" do
    helper.sub_menu_li_for("http://www.google.com").should == "<li><a href=\"http://www.google.com\">http://www.google.com</a></li>"
  end
  
  describe "date methods" do
    before(:each) do
      @now = "2005-07-23".to_time
      Time.stub!(:now).and_return(@now)
      
      @then = '2009-07-19'.to_time
    end
    
    describe "smart date" do
      it "should show a date range" do
        helper.smart_date(@now, @then).should == "Jul 23, 2005 - Jul 19, 2009"
      end
    end
    
    describe "timeago" do
      it "should show a time in the past" do
        helper.timeago(@now).should == "on Jul 23, 2005"
      end
    end
    
    describe "distance of time in words" do
      it "should show a time in the past" do
        minutes = ("2010-01-02".to_time - "2010-01-01".to_time)/60
        helper.cubeless_distance_of_time_in_words(minutes).should == "about one day"
      end
    end
  end # date methods
  
  describe "messages and alerts" do
    before(:each) do
      @message = "This is a message"
      @message.stub!(:link_to_url).and_return("MSG_PATH")
      @message.stub!(:image_path).and_return("MSG_IMG")
      
      @alert = "This is an alert"
    end
    
    it "should display the marketing image tag" do
      helper.marketing_image_tag(@message).should == "<a href=\"MSG_PATH\"><img alt=\"\" height=\"150\" src=\"/images/marketing_MSG_IMG_large.jpg\" width=\"399\" /></a>"
    end
    
    it "should display the marketing image path" do
      helper.marketing_image_path(@message).should == "/images/marketing_MSG_IMG_large.jpg"
    end
  end # messages and alerts
  
  describe "buttons and links" do
    it "should display a link button remote" do
      helper.link_button_remote("link", {:url => "/url"}).should == "<div style=\"\"><a href=\"/url\" class=\"large  button\" data-remote=\"true\">link</a></div>"
    end
    it "should display a small link button remote" do
      helper.small_link_button_remote("link", {:url => "/url"}).should == "<div style=\"\"><a href=\"/url\" class=\"little  button\" data-remote=\"true\">link</a></div>"
    end
    it "should display a submit button" do
      helper.submit_button("submit").should == "<div align=\"center\" class=\"clear\" style=\"\"><input class=\"large  button\" name=\"commit\" onclick=\"\" type=\"submit\" value=\"submit\" /></div>"
    end
    it "should display a link button" do
      helper.link_button("link", :controller => "users", :action => "index").should == "<a href=\"/users\" class=\"large  button\">link</a>"
    end
    it "should display a small button" do
      helper.small_button("link", :controller => "users", :action => "index").should == "<a href=\"/users\" class=\"little  button\">link</a>"
    end
    it "should display a primary small button" do
      helper.primary_small_button("link", "/url").should == "<a href=\"/url\" class=\"little  button\">link</a>"
    end
    it "should display a secondary small button" do
      helper.secondary_small_button("link", "/url").should == "<a href=\"/url\" class=\"little light button\">link</a>"      
    end
    it "should display a link to delete a group post" do
      @post = mock_model(GroupPost)
      @group = mock_model(Group, :editable_by? => true)
      
      helper.link_for_group_post_delete(@post,@group).should == "<a href=\"/group_posts/#{@post.id}\" class=\"modal delete\">delete</a>"
    end
    it "should display a mark as shady link" do
      @question = mock_model(Question)
      helper.link_to_mark_shady(@question).should == "<a href=\"/questions/#{@question.id}/abuse/new\" class=\"modal\">shady</a>"
    end
    it "should display a link to author" do
      @profile.stub!(:is_sponsored?).and_return(false)
      @profile.stub!(:visible?).and_return(true)
      
      @user = mock_model(User, :profile => @profile)
      helper.link_to_author(@user).should == "<a href=\"/profiles/#{@profile.id}\" class=\"karma_level_-1\">Mark McSpadden</a>"
    end    
    it "should display a link to a profile" do
      @profile.stub!(:is_sponsored?).and_return(false)
      @profile.stub!(:visible?).and_return(true)
      
      helper.link_to_profile(@profile).should == "<a href=\"/profiles/#{@profile.id}\" class=\"karma_level_-1\">Mark McSpadden</a>"      
    end
    it "should display a link to a shady abuse" do
      @question = mock_model(Question)
      @abuse = mock_model(Abuse, :abuseable => @question, :abuseable_type => "Question")
      
      helper.link_to_shady_abuse(@abuse).should == "<a href=\"/questions/#{@question.id}\">Question</a>"
    end
    it "should display a link to edit" do
      helper.link_to_edit("/edit_url").should == "<a href=\"/edit_url\" class=\"modal\" data-method=\"get\" data-remote=\"true\">edit</a>"
    end
    it "should display a link to a question referral owner" do
      helper.link_to_question_referral_owner(@profile).should == "<a href=\"/profiles/#{@profile.id}\">Mark McSpadden</a>"
    end
    it "should display a link for group actions" do

    end
    it "should display a link for group member action" do
      @group = mock_model(Group, :invitation_can_be_accepted_or_sent_by? => true)
      
      helper.link_for_group_members_action(@group).should == "<a href=\"/group_invitations/new?group_id=#{@group.id}\" class=\"modal invite\">invite someone</a>"
    end
    it "should display a link to resend action" do
      @group = mock_model(Group, :invitation_can_be_accepted_or_sent_by? => true)
      
      helper.link_for_resend_action(@group).should == "<a href=\"/groups/#{@group.id}/resend_all\" class=\"invite_all\">Resend ALL Invitations</a>"
    end
    it "should display a confirm popup" do
      @message = "Hello World!"
      @options = {:no_image=>{:alt=>"No"}, :no_function=>"cClick(); return false;", :yes_image=>{:alt=>"Yes"}}
      
      helper.should_receive(:render).with(:partial => 'shared/confirm_popup', :locals => {:message => @message, :options => @options}).and_return("POPUP PARTIAL VIEW")
      
      helper.confirm_popup(@message,options={}).should == "showPopup('POPUP PARTIAL VIEW'); return false;"
    end
  end # buttons and links
  
  it "should replace newlines with br" do
    helper.replace_newline_with_br("Mark\nShevawn").should == "Mark<br/>Shevawn"
  end
  
  describe "renders" do
    it "should render abuse" do
      @abuse = mock_model(Abuse)
      
      helper.should_receive(:render).with(:partial => "abuses/show")
      helper.render_abuse(@abuse)
    end
    
    it "should render watch link" do
      @watch = mock_model(Watch)
      @watches = []
      
      helper.current_profile.stub!(:watches => @watches)
      
      @watches.should_receive(:find_by_watchable_type_and_watchable_id).and_return(@watches)      
      
      helper.render_watch_link(@profile).should == "<span class='clicked'>following</span>"
    end
   
    describe "pagination" do
      before(:each) do
        @collection = [1,2,3]
        @options = {:page_var => 1, :ajax => false}
      end
      
      it "should render pagination" do
        helper.should_receive(:render).with(:partial => 'shared/paginate', :locals => { :collection => @collection, :page_var => @options[:page_var], :ajax => @options[:ajax]})

        helper.render_pagination(@collection, @options)
      end

      it "should render windowed pagination links" do
        @options[:window_size] = 1000
        @collection.stub!(:page).and_return(1)
        @collection.stub!(:page_exists?).and_return(false)
        @collection.stub!(:last_page).and_return(3)
        
        lambda{ helper.windowed_pagination_links(@collection, @options) }
      end
    end # pagination
    
    it "should render the inlne editor" do
      @question = mock_model(Question, :title => "What's up?", :editable_by? => true)
      
      helper.render_inline_editor_for(@question, "title", "/questions/edit", options = {}).should include("inline_editable")
    end
    
      
  end # renders
  
  describe "accessors" do
    it "should get the local js gen" do
      ApplicationHelper::LocalJavaScriptGenerator.should_receive(:new)
      helper.local_js_gen
    end
    it "should get the theme colors" do
      helper.theme_colors.should == Config['themes'][Config[:theme]]
    end
    it "should get the site base url" do
      helper.site_base_url.should == URI.parse(Config[:site_base_url]).to_s
    end
    it "should get the site name" do
      helper.site_name.should == Config[:site_name]
    end
    it "should get the sso logout url" do
      helper.sso_logout_url.should == Config[:tfce_sso_logout_url]
    end
    it "should get the sso portal url" do
      helper.sso_portal_url.should == Config[:tfce_sso_portal_url]
    end
    it "should get the sso portal url text" do
      helper.sso_portal_url_text.should == Config[:tfce_sso_portal_url_text]
    end
  end # accessors  
end