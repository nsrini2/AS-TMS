class MarketingMessagesController < ApplicationController

  allow_access_for :all => :content_admin

  before_filter :set_marketing_message

  def new
    respond_to do |format|
      format.js { render(:partial => 'marketing_messages/upload_image_popup', :layout => '/layouts/popup') }
    end
  end

  def create
    @message.marketing_image = MarketingImage.new(params[:asset])
    @message.save if @message.marketing_image.valid?
    respond_to do |format| 
      format.html {
        add_to_errors([@message, @message.marketing_image].compact)
        if flash[:errors].blank?
          add_to_notices "The marketing message has been created"
          return redirect_to marketing_messages_admin_path+"#marketing_message_#{@message.id}"
        else
          return redirect_to marketing_messages_admin_path
          flash[:errors] = nil
        end
      }
    end
  end

  def edit
    respond_to do |format|
      format.js { render(:partial => 'marketing_messages/upload_image_popup', :layout => '/layouts/popup', :locals => { :msg => @message }) }
    end
  end

  def update
    @message.update_attributes( params[:marketing_message] ) if params[:marketing_message]
    @message.marketing_image.update_attributes( params[:asset] ) if params[:asset]
    respond_to do |format|
      format.html {
         add_to_errors([@message, @message.marketing_image].compact)
         if flash[:errors].blank?
           add_to_notices "The marketing message has been successfully updated"
           return redirect_to marketing_messages_admin_path
         else
           return redirect_to marketing_messages_admin_path
           flash[:errors] = nil
         end
       }
       format.json{
        render :json => @message
     }
    end
  end

  def destroy
    @message.destroy
    respond_to do |format|
      format.html { redirect_to :back }
    end
  end

  def toggle_activation
    @message.toggle_activation
    respond_to do |format|
      format.html { redirect_to :back }
      format.json { render :text => @message.to_json }
    end
  end

  private

  def set_marketing_message
    @message = MarketingMessage.find_or_initialize_by_id(params[:id])
  end

end
