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
    if @activity_stream_message.save
      flash[:notice] = "Activity Stream Message Created"
      redirect_to activity_stream_messages_admin_path
    else  
      flash[:errors] = "An error occured creating Activity Stream Message."
      render :action => "new"
    end  
  end
  
  def edit
    @activity_stream_message = ActivityStreamMessage.find_by_id(param[:id])
  end
  
  def update
    render :text => "update"
  end
  
  def destroy
    render :text => "destroy"
  end
  
  def toggle_activation
    @activity_stream_message = ActivityStreamMessage.find_by_id(param[:id])
    @activity_stream_message.toggle_activation
    respond_to do |format|
      format.html { redirect_to :back }
      format.json { render :text => @message.to_json }
    end
  end
end  