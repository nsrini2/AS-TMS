class TravelsController < ApplicationController
  deny_access_for :all => :sponsor_member
  before_filter :verify_travel_enabled

  before_filter :get_profile
  before_filter :authorize_profile
  
  before_filter :get_booking
  before_filter :authorize_booking
  
  
  def index
    @travels = current_profile.getthere_bookings.current_and_upcoming #GetthereBooking.find(:all)
    render :layout => "_my_stuff"
  end
  
  def itinerary  
    # Get xmls from travel    
    @bxml = BookingXML.new(REXML::Document.new(@travel.xml).root)
    
    options = {}
    
    options[:selected_tab] = :travels_tab
    
    # MM2
    # I copied this from ExplorationsController#render_new_exploration_page
    # I don't fully understand it, but it gets me the exploration tabs I need.
    @cloud_terms = top_terms(options[:tag_cloud_for].to_sym) if options[:tag_cloud_for]
    @selected = options[:selected_tab].to_s
    @explore_text = options[:search_text].to_s
    @form_action = options[:form_action].to_s if options[:form_action]
        
    layout = @profile ? '_my_stuff' : 'exploration'    
        
    render :layout => layout
  end
  
  
  def toggle_privacy      
    new_public =  if params[:share]
                    params[:share].to_s == "true" ? true : false
                  else
                    !@travel.public ? true : false
                  end

    if @travel.update_attribute(:public, new_public)
      if request.xhr?
        render(:text => { :new_public => new_public }.to_json)
      else
        add_to_notices 'This trip is now shared.'
        redirect_to profile_travels_path(current_profile)
      end
    else
      if request.xhr?
        render(:text => { :errors => ["There was an error in updating this trip."] }.to_json)
        flash[:errors] = nil
      else
        add_to_notices 'There was an ERROR in trying to share your trip.'
        redirect_to profile_travels_path(current_profile)        
      end
    end

  end
  
  private
  def get_profile
    if params[:profile_id]
      @profile = Profile.find(params[:profile_id])
    end
  end
  def authorize_profile
    if @profile && @profile != current_profile
      respond_not_authorized and return
    end
  end
  def get_booking
    if params[:id]
      @travel = GetthereBooking.find(params[:id])
    end
  end
  def authorize_booking
    if @travel && @travel.profile != current_profile
      unless params[:action] == "itinerary" && @travel.public
        respond_not_authorized and return
      end
    end
  end
  
end