class BoothMarketingMessagesController < ApplicationController
  
  before_filter :set_group_booth_marketing_message
  before_filter :find_booth_details

 def index
      @booth_marketing_messages = BoothMarketingMessage.find(:all, :conditions => ['group_id =?',@group.id]).paginate(:page => params[:booth_marketing_page], :per_page => 5)
     render :layout => '/layouts/sponsored_group_manage_sub_menu'
 end

 def new
    respond_to do |format|
      format.js { render(:partial => 'booth_marketing_messages/upload_image_popup', :layout => '/layouts/popup') }
    end
  end

  def create
    @message=BoothMarketingMessage.new(
    :marketing_image => MarketingImage.new(params[:asset]),
    :group_id => params[:group_id])
    @message.save if @message.marketing_image.valid?
    respond_to do |format| 
      format.html {
        add_to_errors([@message, @message.marketing_image].compact)
        if flash[:errors].blank?
          flash[:notice]= "A new marketing message for the booth page has been created"
          return redirect_to group_booth_marketing_messages_path(@group)
        else
          return redirect_to group_booth_marketing_messages_path(@group)
          flash[:errors] = nil
        end
      }
    end
  end

  def edit
    respond_to do |format|
      format.js { render(:partial => 'booth_marketing_messages/upload_image_popup', :layout => '/layouts/popup', :locals => { :msg => @message }) }
    end
  end

  def update
    @message.update_attributes( params[:booth_marketing_message] ) if params[:booth_marketing_message]
    @message.marketing_image.update_attributes( params[:asset] ) if params[:asset]
    respond_to do |format|
      format.html {
         add_to_errors([@message, @message.marketing_image].compact)
         if flash[:errors].blank?
           flash.now[:notice] = "The booth marketing message was successfully updated"
           redirect_to booth_marketing_messages_path
         else
           redirect_to booth_marketing_messages_path
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

  def set_group_booth_marketing_message
    @group = Group.find(params[:group_id])
    @booth_marketing_messages = @group.booth_marketing_messages.all
    @message = BoothMarketingMessage.find_or_initialize_by_id(params[:id])
  end

  def find_booth_details
    @group = Group.find(params[:group_id])
    @group_links = @group.group_links.all
     max_id = Group.count_by_sql("select min(profile_id) from (select profile_id from group_memberships where group_id = #{@group.id} order by profile_id desc limit 200) as x")
    @booth_members = @group.members.all(:conditions => "profiles.id >= #{rand(max_id)+1}", :limit => 20).to_a.sort! { |a,b| rand(3)-1 }
  end

end