class SiteAdmin::SiteProfileFieldsController < ApplicationController
  allow_access_for :all => :cubeless_admin

  layout 'site_admin'
  
  before_filter :setup_selected_tab
  def setup_selected_tab
    @selected = "profile_basic_tab"
  end
  
  before_filter :cancel_button_reset, :only => [:create, :update, :update_profile_page, :update_biz_card]
  def cancel_button_reset
    redirect_to site_admin_site_profile_fields_path and return if params[:reset]
  end  

  # GET /site_profile_fields
  # GET /site_profile_fields.xml
  def index
    @site_profile_fields = SiteProfileField.find(:all)
    site_profile_page
    site_biz_card

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @site_profile_fields }
    end
  end

  # GET /site_profile_fields/1
  # GET /site_profile_fields/1.xml
  def show
    @site_profile_field = SiteProfileField.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @site_profile_field }
    end
  end

  # GET /site_profile_fields/new
  # GET /site_profile_fields/new.xml
  def new
    @site_profile_field = SiteProfileField.new
    @site_profile_field.question = SiteProfileField.question_names_available.first

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @site_profile_field }
    end
  end

  # GET /site_profile_fields/1/edit
  def edit
    @site_profile_field = SiteProfileField.find(params[:id])
  end
  
  # GET /site_profile_fields/edit_profile_page
  def edit_profile_page
    @site_profile_field = SiteProfileField.new
    site_profile_page
  end
  
  # POST /site_profile_fields/update_profile_page
  def update_profile_page    
    if params[:fields]
      params[:fields].each_pair do |k,v|
        page = SiteProfilePage.find(k)
        
        # -2 accounts for the 2 static entries
        # Anything less than 0 should just be 0
        position = v.to_i-2
        position < 0 ? 0 : position
        
        page.update_attribute(:position, position) 
      end
    end
    
    redirect_to site_admin_site_profile_fields_path
  end

  # GET /site_profile_fields/edit_biz_card
  def edit_biz_card
    @site_profile_field = SiteProfileField.new
    site_biz_card
  end
  
  # POST /site_profile_fields/update_biz_card
  def update_biz_card
    if params[:fields]
      params[:fields].each_pair do |k,v|
        page = SiteBizCard.find(k)
        
        # -2 accounts for the 2 static entries
        # Anything less than 0 should just be 0
        position = v.to_i-2
        position < 0 ? 0 : position
        
        page.update_attribute(:position, position) 
      end
    end
    
    redirect_to site_admin_site_profile_fields_path
  end

  # POST /site_profile_fields
  # POST /site_profile_fields.xml
  def create
    @site_profile_field = SiteProfileField.new(params[:site_profile_field])

    respond_to do |format|
      if @site_profile_field.save
        flash[:notice] = 'Field was successfully created.'
        format.html { redirect_to(site_admin_site_profile_fields_path) }
        format.xml  { render :xml => @site_profile_field, :status => :created, :location => @site_profile_field }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @site_profile_field.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /site_profile_fields/1
  # PUT /site_profile_fields/1.xml
  def update
    @site_profile_field = SiteProfileField.find(params[:id])

    respond_to do |format|
      if @site_profile_field.update_attributes(params[:site_profile_field])
        flash[:notice] = 'Field was successfully updated.'
        format.html { redirect_to(site_admin_site_profile_fields_path) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @site_profile_field.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /site_profile_fields/1
  # DELETE /site_profile_fields/1.xml
  def destroy
    @site_profile_field = SiteProfileField.find(params[:id])
    @site_profile_field.destroy

    respond_to do |format|
      format.html { redirect_to(site_admin_site_profile_fields_url) }
      format.xml  { head :ok }
    end
  end
  
  private
  def site_profile_page
    @site_profile_page = SiteProfileField.find(:all)

    # Just in case the field doesn't have a profile page
    @site_profile_page.each{ |spp| spp.create_site_profile_page(:position => 0) unless spp.site_profile_page }


    @stuck_profile_page = @site_profile_page.select{ |spp| spp.sticky? }
    @out_profile_page = @site_profile_page.select{ |spp| spp.profile_page_position <= 0 && !@stuck_profile_page.include?(spp) }
    
    @site_profile_page.delete_if{ |spp| @stuck_profile_page.include?(spp) || @out_profile_page.include?(spp) }
    
    @site_profile_page = @site_profile_page.sort_by(&:profile_page_position)
    @stuck_profile_page = @stuck_profile_page.sort_by(&:question)
  end
  
  def site_biz_card
    @site_biz_card = SiteProfileField.find(:all)

    # Just in case the field doesn't have a biz card
    @site_biz_card.each{ |sbc| sbc.create_site_biz_card(:position => 0) unless sbc.site_biz_card }

    @stuck_biz_card = @site_biz_card.select{ |sbc| sbc.sticky? }
    @out_biz_card = @site_biz_card.select{ |sbc| sbc.biz_card_position <= 0 && !@stuck_biz_card.include?(sbc) }
    
    @site_biz_card.delete_if{ |sbc| @stuck_biz_card.include?(sbc) || @out_biz_card.include?(sbc) }
    
    @site_biz_card = @site_biz_card.sort_by(&:biz_card_position)
    @stuck_biz_card = @stuck_biz_card.sort_by(&:question)
    
    

  end
end
