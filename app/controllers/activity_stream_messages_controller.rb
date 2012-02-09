class ActivityStreamMessagesController < ApplicationController
  layout 'home_admin_sub_menu'
  
  def index
    redirect_to activity_stream_messages_admin_path
  end
  
  def show
    redirect_to activity_stream_messages_admin_path
  end
  
  def new
  end
  
  def create
    @activity_stream_message = ActivityStreamMessage.new(params[:activity_stream_message])
    if params[:asset]
      @activity_stream_message.activity_stream_message_photo = ActivityStreamMessagePhoto.new(params[:asset])
    end  
    if @activity_stream_message.save
      flash[:notice] = "Activity Stream Message Created"
      redirect_to activity_stream_messages_admin_path
    else  
      flash[:errors] = "An error occured creating Activity Stream Message."
      render :action => "new"
    end  
  end
  
  def edit
    @activity_stream_message = ActivityStreamMessage.find_by_id(params[:id])
  end
  
  def update
    @activity_stream_message = ActivityStreamMessage.find_by_id(params[:id])
    if params[:asset]
      @activity_stream_message.activity_stream_message_photo = ActivityStreamMessagePhoto.new(params[:asset])
    end  
    @activity_stream_message.update_attributes(params[:activity_stream_message])
    if @activity_stream_message.save
      flash[:notice] = "Activity Stream Message has been updated!"
      redirect_to activity_stream_messages_admin_path
    else
      flash[:errors] = @activity_stream_message.errors
      render :action => "create" 
    end    
  end
  
  def destroy
    render :text => "destroy"
  end
  
  def toggle_activation
    @activity_stream_message = ActivityStreamMessage.find_by_id(params[:id])
    @activity_stream_message.toggle_activation
    @activity_stream_message.save
    respond_to do |format|
      format.html { redirect_to :back }
      format.json { render :text => @activity_stream_message.to_json }
    end
  end
end  