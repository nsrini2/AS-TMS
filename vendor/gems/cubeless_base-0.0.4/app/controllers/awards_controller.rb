class AwardsController < ApplicationController

  allow_access_for :all => :awards_admin

  before_filter :set_award, :except => 'create'
  layout 'awards_sub_menu'

  def new
    
  end

  def create
    @award = Award.new(:title => params[:award][:title])
    if params[:asset][:uploaded_data].blank?
      add_to_errors "We need an image for this award"
    else
      @award.award_image = AwardImage.new(params[:asset])
      respond_to do |format|
        if @award.save
          format.html { 
            add_to_notices"Award has been saved!"
            return redirect_to(current_awards_admin_path)
          }
        else
          format.html { add_to_errors [@award, @award.award_image] }
        end 
      end
    end
    render :action => 'new'
  end

  def update
    
    if params[:asset] && !params[:asset][:uploaded_data].blank?
      @award.award_image = AwardImage.new(params[:asset])
    end
    @award.update_attributes( params[:award] )
    respond_to do |format|
      if @award.save
        format.html { 
          add_to_notices "#{@award.title} has been saved"
          redirect_to current_awards_admin_path 
        }
        format.json { render :text => @award.to_json }
      else
        format.html { add_to_errors [@award, @award.award_image] }
      end
    end
  end

  def update_image
    responds_to_parent do
      @award.award_image.update_attributes params[:asset]
      render_awards
    end
  end

  def copy
    @award.copy!
    add_to_notices "#{@award.title} has been copied. Be sure to change the name!"
    render :text => ""
  end

  def toggle_visibility
    @award.toggle_visibility!
    @awards = Award.visibility_not_matching(@award).find(:all, :page => {:size => 5, :current => params[:page]})
    render :partial => "awards/awards"
  end

  def assign_award
    award = Award.find(params[:id])
    respond_to do |format|
      format.html { render(:partial => 'awards/assign_award_popup', :layout => 'awards_sub_menu', :locals => { :award_id => params[:id] }) }
      format.js { render(:partial => 'awards/assign_award_popup', :layout => '/layouts/popup', :locals => { :award_id => params[:id] }) }
    end
  end

  private

  def render_awards
    render :update do |page|
      @awards = Award.visibility_matching(@award).find(:all, :page => {:size => 5, :current => params[:page]})
      page.call 'cClick'
      page["admin_award_list"].replace_html :partial => 'awards/awards'
      replace_flash_error_for(page, @award.award_image)
    end
  end

  def set_award
    @award = Award.find_or_initialize_by_id(params[:id])
  end

end