class SiteAdmin::SiteProfileQuestionSectionsController < ApplicationController
  allow_access_for :all => :cubeless_admin
  
  layout 'site_admin'
  
  before_filter :setup_selected_tab
  def setup_selected_tab
    @selected = "profile_advanced_tab"
  end
  
  before_filter :cancel_button_reset, :only => [:create, :update, :reorder]
  def cancel_button_reset
    redirect_to site_admin_site_profile_questions_path and return if params[:reset]
  end


  # GET /site_profile_question_sections
  # GET /site_profile_question_sections.xml
  def index
    @site_profile_question_sections = SiteProfileQuestionSection.find(:all, :order => :position)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @site_profile_question_sections }
    end
  end

  # GET /site_profile_question_sections/1
  # GET /site_profile_question_sections/1.xml
  def show
    @site_profile_question_section = SiteProfileQuestionSection.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @site_profile_question_section }
    end
  end

  # GET /site_profile_question_sections/new
  # GET /site_profile_question_sections/new.xml
  def new
    @site_profile_question_section = SiteProfileQuestionSection.new
    @site_profile_question_section.position = SiteProfileQuestionSection.count+1

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @site_profile_question_section }
    end
  end

  # GET /site_profile_question_sections/1/edit
  def edit
    @site_profile_question_section = SiteProfileQuestionSection.find(params[:id])
  end
  
  # GET /site_profile_question_sections/edit_order
  def edit_order
    @site_profile_question_section = SiteProfileQuestionSection.new
    @site_profile_question_sections = SiteProfileQuestionSection.find(:all, :order => :position)    
  end
  
  # POST /site_profile_question_sections/reorder
  def reorder    
    if params[:sections]
      params[:sections].each_pair do |k,v|
        section = SiteProfileQuestionSection.find(k)
        section.update_attribute(:position, v.to_i)
      end
    end
    
    redirect_to site_admin_site_profile_questions_path
  end  

  # GET /site_profile_question_sections/1/edit_questionsorder
  def edit_questions_order
    @site_profile_question_section = SiteProfileQuestionSection.find(params[:id])
    @site_profile_questions = @site_profile_question_section.site_profile_questions
    # @site_profile_question_sections = SiteProfileQuestionSection.find(:all, :order => :position)    
  end
  
  # POST /site_profile_question_sections/1/reorder_questions
  def reorder_questions    
    if params[:questions]
      params[:questions].each_pair do |k,v|
        section = SiteProfileQuestion.find(k)
        section.update_attribute(:position, v.to_i)
      end
    end
    
    redirect_to site_admin_site_profile_questions_path
  end

  # POST /site_profile_question_sections
  # POST /site_profile_question_sections.xml
  def create
    @site_profile_question_section = SiteProfileQuestionSection.new(params[:site_profile_question_section])

    respond_to do |format|
      if @site_profile_question_section.save
        flash[:notice] = 'Profile Question Section was successfully created.'
        format.html { redirect_to(site_admin_site_profile_questions_path) }
        format.xml  { render :xml => @site_profile_question_section, :status => :created, :location => @site_profile_question_section }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @site_profile_question_section.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /site_profile_question_sections/1
  # PUT /site_profile_question_sections/1.xml
  def update
    @site_profile_question_section = SiteProfileQuestionSection.find(params[:id])

    respond_to do |format|
      if @site_profile_question_section.update_attributes(params[:site_profile_question_section])
        flash[:notice] = 'Profile Question Section was successfully updated.'
        format.html { redirect_to(site_admin_site_profile_questions_path) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @site_profile_question_section.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /site_profile_question_sections/1
  # DELETE /site_profile_question_sections/1.xml
  def destroy
    @site_profile_question_section = SiteProfileQuestionSection.find(params[:id])
    @site_profile_question_section.destroy

    respond_to do |format|
      format.html { redirect_to(site_admin_site_profile_questions_path) }
      format.xml  { head :ok }
    end
  end
end
