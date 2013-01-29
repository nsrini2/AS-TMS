require File.dirname(__FILE__) + '/../spec_helper'

describe ProfilesHelper do
  before(:each) do
    @profile = mock_model(Profile)
    helper.stub!(:current_profile).and_return(@profile)
  end
  
  
  describe "empty watch list content for" do
    it "should return nil if there are questions" do
      helper.empty_watch_list_content_for([1,2,3]).should == nil
    end
    it "should create a div with image if the watch list is empty" do
      w_img = helper.image_tag("/images/watchList.gif")
      
      helper.empty_watch_list_content_for([]).should == "<div align=\"center\">#{w_img}</div>"
    end
  end
  
  it "should render widget home ask question" do
    helper.should_receive(:render).with(:partial => 'widgets/ask_question')
    helper.render_widget_home_ask_question
  end
  
  it "should render widget home explore profiles" do
    helper.should_receive(:render).with(:partial => 'widgets/explore_profiles')
    helper.render_widget_home_explore_profiles
  end
  
  it "should render widget watch list" do
    helper.should_receive(:render).with(:partial => 'widgets/questions', :locals => {
      :title => "Watch List (#{[].size})",
      :questions => [],
      :show => {:avatar => true, :asked_by => true},
      :view_all_url => watched_questions_profile_path(@profile),
      :empty_widget_message => "You're not stalking any questions right now. You can always find more by #{link_to "exploring questions", questions_explorations_path, :class => 'empty'}"
    })
    helper.render_widget_watch_list([])
  end
  
  it "should render widget home notes" do
    helper.should_receive(:render).with(:partial => 'widgets/recent_notes')
    helper.render_widget_home_notes
  end
  
  it "should render widget random terms" do
    helper.should_receive(:render).with(:partial => 'widgets/hot_topics')
    helper.render_widget_random_terms
  end
end