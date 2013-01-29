class SiteAdmin::SiteRegistrationFieldsController < ApplicationController
  allow_access_for :all => :cubeless_admin

  layout 'site_admin'

  # helper :site_registration_fields
  
  before_filter :setup_selected_tab
  def setup_selected_tab
    @selected = "registration_fields_tab"
  end
  
  before_filter :cancel_button_reset, :only => [:create, :update, :reorder]
  def cancel_button_reset
    redirect_to site_admin_site_registration_fields_path and return if params[:reset]
  end
  
  # GET /site_registration_fields
  # GET /site_registration_fields.xml
  def index
    @site_registration_fields = SiteRegistrationField.find(:all, :order => :position)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @site_registration_fields }
    end
  end

  # GET /site_registration_fields/1
  # GET /site_registration_fields/1.xml
  def show
    @site_registration_field = SiteRegistrationField.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @site_registration_field }
    end
  end

  # GET /site_registration_fields/new
  # GET /site_registration_fields/new.xml
  def new
    @site_registration_field = SiteRegistrationField.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @site_registration_field }
    end
  end

  # GET /site_registration_fields/1/edit
  def edit
    @site_registration_field = SiteRegistrationField.find(params[:id])
  end
  
  # GET /site_registration_fields/edit_order
  def edit_order
    @site_registration_field = SiteRegistrationField.new
    @site_registration_fields = SiteRegistrationField.find(:all)    
  end
  
  # POST /site_registration_fields
  def reorder    
    if params[:categories]
      params[:categories].each_pair do |k,v|
        category = SiteRegistrationField.find(k)
        category.update_attribute(:position, v.to_i)
      end
    end
    
    redirect_to site_admin_site_registration_fields_path
  end

  # POST /site_registration_fields
  # POST /site_registration_fields.xml
  def create
    @site_registration_field = SiteRegistrationField.new(params[:site_registration_field])

    respond_to do |format|
      if @site_registration_field.save
        flash[:notice] = 'Registration Field was successfully created.'
        format.html { redirect_to site_admin_site_registration_fields_path }
        format.xml  { render :xml => @site_registration_field, :status => :created, :location => @site_registration_field }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @site_registration_field.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /site_registration_fields/1
  # PUT /site_registration_fields/1.xml
  def update
    @site_registration_field = SiteRegistrationField.find(params[:id])

    respond_to do |format|
      if @site_registration_field.update_attributes(params[:site_registration_field])        
        flash[:notice] = 'Registration Field was successfully updated.'
        format.html { redirect_to(site_admin_site_registration_fields_path) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @site_registration_field.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /site_registration_fields/1
  # DELETE /site_registration_fields/1.xml
  def destroy
    @site_registration_field = SiteRegistrationField.find(params[:id])
    @site_registration_field.destroy

    respond_to do |format|
      format.html { redirect_to(site_admin_site_registration_fields_url) }
      format.xml  { head :ok }
    end
  end
end
