class RssFeedsController < ApplicationController
  layout 'home_admin_sub_menu'
  
  def index
    redirect_to rss_feeds_admin_path
  end
  
  def show
    redirect_to rss_feeds_admin_path
  end
  
  def new
  end
  
  def create
    @rss_feed = RssFeed.new(params[:rss_feed])
    if params[:asset]
      @rss_feed.primary_photo = RssFeedPhoto.new(params[:asset])
    end
    if @rss_feed.save
      flash[:notice] = "RSS Feed Created"
      redirect_to rss_feeds_admin_path
    else  
      add_to_errors @rss_feed
      render :action => "new"
    end  
  end
  
  def edit
    @rss_feed = RssFeed.find_by_id(params[:id])
  end
  
  def update
    @rss_feed = RssFeed.find_by_id(params[:id])
    @rss_feed.update_attributes(params[:rss_feed])
    if params[:asset]
      @rss_feed.primary_photo = RssFeedPhoto.new(params[:asset])
    end
    
    if @rss_feed.save
      flash[:notice] = "RSS Feed has been updated!"
      redirect_to rss_feeds_admin_path
    else
      # flash[:errors] = @rss_feed.errors
      add_to_errors @rss_feed
      render :action => "edit" 
    end    
  end
  
  def destroy
    render :text => "destroy"
  end
  
  def toggle_activation
    @rss_feed = RssFeed.find_by_id(params[:id])
    @rss_feed.toggle_activation
    @rss_feed.save!
    respond_to do |format|
      format.html { redirect_to :back }
      format.json { render :text => @rss_feed.to_json }
    end
  end
end
