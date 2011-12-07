class SiteAdminController < ApplicationController
  allow_access_for :all => :cubeless_admin

  layout 'site_admin'
  
  before_filter :setup_selected_tab
  def setup_selected_tab
    @selected = "#{params[:action]}_tab"
  end

  def index

  end

  def general
    @config = SiteConfig.first || SiteConfig.create!
    
    @themes = Config['themes'].collect{ |t| ["#{t[0].titlecase} - #{t[1]['description']}", t[0]] }
    @theme_options = @themes.sort{ |a,b| a[1].split("_")[1].to_i  <=> b[1].split("_")[1].to_i }
  end

  def publish_general
    @config = SiteConfig.first
    
    if @config.update_attributes(params[:site_config])    
      flash[:notice] = "Success"
      redirect_to general_site_admin_url
    else
      flash[:errors] = "Error"
      redirect_to general_site_admin_url
    end
  end
  
  def edit_logo
    respond_to do |format|
      format.js { render :partial => "upload_logo", :layout => "/layouts/popup" }
    end
  end
  
  def update_logo
    @site_config = SiteConfig.first
    @logo
    
    @logo = SiteLogo.new(params[:asset])
    @site_config.site_logos << @logo
    
    respond_to do |format|
      format.html {
         add_to_errors @logo     
         redirect_to general_site_admin_path
      }
    end
  end

  def edit_favicon
    respond_to do |format|
      format.js { render :partial => "upload_favicon", :layout => "/layouts/popup" }
    end
  end
  
  def update_favicon
    @site_config = SiteConfig.first
    @favicon
    
    @favicon = SiteFavicon.new(params[:asset])
    @site_config.site_favicons << @favicon
    
    respond_to do |format|
      format.html {
         add_to_errors @favicon
         redirect_to general_site_admin_path
      }
    end
  end

  def profile_basic
    
  end
  
  def profile_advanced
    
  end
  
  def question_categories
    
  end
  


end
