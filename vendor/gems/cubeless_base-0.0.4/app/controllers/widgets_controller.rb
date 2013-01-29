class WidgetsController < ApplicationController
  
  allow_access_for [:index, :new, :edit, :default_widget, :create, :update, :destroy] => :content_admin
  
  caches_action :show

  layout 'home_admin_sub_menu'
  
  def index
    @default_widget = DefaultWidget.get
    @widgets = Widget.all
  end
  
  def show
    @widget = Widget.find(params[:id])
    render :layout => false
  end
  
  def new
    @widget = Widget.new
  end
  
  def default_widget
    @object = DefaultWidget.get
  end

  def edit
    @widget = Widget.find(params[:id])
  end

  # def create
  #   Widget.get.update_attributes params[:object]
  #   redirect_to widget_admin_path
  # end
  
  def create
    @widget = Widget.new(params[:widget])
    respond_to do |format|
      if @widget.save
        format.html { redirect_to widgets_path }
      else
        format.html { render :action => "new" }
      end
    end
  end
  
  def update
    @widget = Widget.find(params[:id])
    respond_to do |format|
      if @widget.update_attributes(params[:widget])
        expire_widget_cache
        format.html { redirect_to widgets_path }
      else
        format.html { render :action => "edit" }
      end
    end
  end
  
  def destroy
    @widget = Widget.find(params[:id])
    @widget.destroy
    
    expire_widget_cache
    
    respond_to do |format|
      format.html { redirect_to widgets_path }
    end
  end


  protected
  def expire_widget_cache
    expire_action :action => :show
  end
end