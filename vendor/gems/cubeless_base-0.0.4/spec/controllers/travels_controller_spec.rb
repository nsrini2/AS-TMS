require File.dirname(__FILE__) + '/../spec_helper'

describe TravelsController do
  before(:each) do
    login_as_direct_member
    
    @travel = mock_model(GetthereBooking, :public => true, :xml => "", :profile => controller.current_profile)
    GetthereBooking.stub!(:find).and_return(@travel)
    
    controller.stub!(:verify_travel_enabled).and_return(true)
  end
  
  describe "GET /travels" do
    it "should be successful" do
      get :index
      response.should be_success
    end
    
    it "should lookup the current user's current and upcoming getthere bookings" do
      @bookings = mock("Bookings")
      
      controller.current_profile.should_receive(:getthere_bookings).and_return(@bookings)
      @bookings.should_receive(:current_and_upcoming).and_return([])
      get :index
    end
    
    it "should render with the my_stuff layout" do
      # controller.should_receive(:render).with(:layout => "_my_stuff")
      
      get :index
    end
    
    describe "authorization" do
      it "should not permit you to see travels that aren't yours" do
        profile = mock_model(Profile, :id => "3210")
        Profile.stub!(:find).and_return(profile)
        
        get :index, :profile_id => "3210"
        response.should redirect_to('/profile')
      end
    end
  end
  
  describe "GET /travels/1/itinerary" do
    it "should be successful" do
      get :itinerary, :id => @travel.id.to_s
      response.should be_success
    end
    
    it "should lookup the getthere booking" do
      GetthereBooking.should_receive(:find).with(@travel.id.to_s).and_return(@travel)
      
      get :itinerary, :id => @travel.id.to_s
    end
    
    it "should render the my stuff layout if the trip is mine and I'm looking at it from my stuff" do
      # controller.should_receive(:render).with(:layout => "_my_stuff")
      get :itinerary, :id => @travel.id.to_s, :profile_id => controller.current_profile.id
    end
    it "should render the explorations layout if the trip is not mine" do
      # controller.should_receive(:render).with(:layout => "exploration")
      get :itinerary, :id => @travel.id.to_s
    end
    
    describe "authorization" do
      before(:each) do
        @not_me = mock_model(Profile, :id => 13215)
        Profile.stub!(:find).and_return(@not_me)
      end
      
      it "should not allow outsiders to view my version of the itinerary" do        
        get :itinerary, :id => @travel.id.to_s, :profile_id => @not_me.id
        response.should redirect_to("/profile")
      end
      it "should not allow outsiders to view my itinerary if it's not public" do
        @travel.stub!(:public).and_return(false)
        @travel.stub!(:profile).and_return(@not_me)
        
        get :itinerary, :id => @travel.id.to_s
        response.should redirect_to("/profile")        
      end
      it "should allow outsiders to view my itinerary if it's public" do
        @travel.stub!(:public).and_return(true)
        @travel.stub!(:profile).and_return(@not_me)
        
        get :itinerary, :id => @travel.id.to_s
        response.should be_success
      end
    end
  end
  
  describe "GET /travels/1/toggle_privacy" do
    before(:each) do
      @travel.stub!(:update_attribute).and_return(true)
    end
    
    it "should lookup the getthere booking" do
      GetthereBooking.should_receive(:find).with(@travel.id.to_s).and_return(@travel)
      
      get :toggle_privacy, :id => @travel.id.to_s
    end
    
    it "should update the public attribute of the getthere booking" do
      @travel.should_receive(:update_attribute).and_return(true)
      get :toggle_privacy, :id => @travel.id.to_s      
    end
    
    describe "xhr request" do

    end
    
    describe "get request" do
      it "should redirect to 'My Stuff -> Travel'" do
        get :toggle_privacy, :id => @travel.id.to_s
        response.should redirect_to("/profiles/#{controller.current_profile.id}/travels")
      end
    end
    

    
    describe "authorization" do
      before(:each) do
        @not_me = mock_model(Profile, :id => 13215)
        Profile.stub!(:find).and_return(@not_me)
      end
      
      it "should not allow outsiders to view my version of the itinerary" do        
        get :toggle_privacy, :id => @travel.id.to_s, :profile_id => @not_me.id
        response.should redirect_to("/profile")
      end
      it "should not allow outsiders to view my itinerary if it's not public" do
        @travel.stub!(:public).and_return(false)
        @travel.stub!(:profile).and_return(@not_me)
        
        get :toggle_privacy, :id => @travel.id.to_s
        response.should redirect_to("/profile")        
      end
      it "should not allow outsiders to view my itinerary even if it's public" do
        @travel.stub!(:public).and_return(true)
        @travel.stub!(:profile).and_return(@not_me)
        
        get :toggle_privacy, :id => @travel.id.to_s
        response.should redirect_to("/profile")
      end
    end
  end
  
end