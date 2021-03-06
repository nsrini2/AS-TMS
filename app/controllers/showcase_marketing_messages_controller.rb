class ShowcaseMarketingMessagesController < ApplicationController

  allow_access_for :all => :sponsor_admin

  before_filter :set_showcase_marketing_message

  def new
    respond_to do |format|
      format.js { render(:partial => 'showcase_marketing_messages/upload_image_popup', :layout => '/layouts/popup') }
    end
  end

  def create
    @message.marketing_image = MarketingImage.new(params[:asset])
    @message.save if @message.marketing_image.valid?
    respond_to do |format| 
      format.html {
        add_to_errors([@message, @message.marketing_image].compact)
        if flash[:errors].blank?
          flash[:notice]= "A new marketing message for the travel market showcase page has been created"
          return redirect_to showcase_marketing_messages_admin_path
        else
          return redirect_to showcase_marketing_messages_admin_path
          flash[:errors] = nil
        end
      }
    end
  end

  def edit
    respond_to do |format|
      format.js { render(:partial => 'showcase_marketing_messages/upload_image_popup', :layout => '/layouts/popup', :locals => { :msg => @message }) }
    end
  end

  def update
    @message.update_attributes( params[:showcase_marketing_message] ) if params[:showcase_marketing_message]
    @message.marketing_image.update_attributes( params[:asset] ) if params[:asset]
    respond_to do |format|
      format.html {
         add_to_errors([@message, @message.marketing_image].compact)
         if flash[:errors].blank?
           flash.now[:notice] = "The showcase marketing message was successfully updated"
           redirect_to showcase_marketing_messages_admin_path
         else
           redirect_to showcase_marketing_messages_admin_path
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

  def set_showcase_marketing_message
    @message = ShowcaseMarketingMessage.find_or_initialize_by_id(params[:id])
  end

end
