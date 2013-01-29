class DefaultWidgetsController < ApplicationController

  allow_access_for :all => :content_admin

  def show
    @widget = DefaultWidget.get
    render :template => "/widgets/show", :layout => false
  end

  def create
    if params[:commit] != "Remove"
      DefaultWidget.get.update_attributes params[:object]
      add_to_notices "The default Hub Widget has been saved"
    elsif params[:commit] == "Remove"
      DefaultWidget.get.update_attributes(:content => "")
      add_to_notices "The default Hub Widget is now blank"
    end
    redirect_to widgets_path #default_widget_admin_path
  end

end