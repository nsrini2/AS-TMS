class SiteAdmin::SiteProfileQuestionsController < ApplicationController
  allow_access_for :all => :cubeless_admin

  layout 'site_admin'
  
  before_filter :setup_selected_tab
  def setup_selected_tab
    @selected = "profile_advanced_tab"
  end
  
  before_filter :cancel_button_reset, :only => [:create, :update]
  def cancel_button_reset
    redirect_to site_admin_site_profile_questions_path and return if params[:reset]
  end

  # GET /site_profile_questions
  # GET /site_profile_questions.xml
  def index
    @site_profile_questions = SiteProfileQuestion.find(:all, :order => "site_profile_question_section_id, position")
    
    
    @site_profile_question_sections = SiteProfileQuestionSection.find(:all, :order => :position)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @site_profile_questions }
    end
  end

  # GET /site_profile_questions/1
  # GET /site_profile_questions/1.xml
  def show
    @site_profile_question = SiteProfileQuestion.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @site_profile_question }
    end
  end

  # GET /site_profile_questions/new
  # GET /site_profile_questions/new.xml
  def new
    @site_profile_question = SiteProfileQuestion.new
    @site_profile_question.question = SiteProfileQuestion.question_names_available.first

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @site_profile_question }
    end
  end

  # GET /site_profile_questions/1/edit
  def edit
    @site_profile_question = SiteProfileQuestion.find(params[:id])
  end

  # POST /site_profile_questions
  # POST /site_profile_questions.xml
  def create
    @site_profile_question = SiteProfileQuestion.new(params[:site_profile_question])
    @site_profile_question.position = @site_profile_question.site_profile_question_section.site_profile_questions.count + 1

    respond_to do |format|
      if @site_profile_question.save
        flash[:notice] = 'Profile Question was successfully created.'
        format.html { redirect_to(site_admin_site_profile_questions_path) }
        format.xml  { render :xml => @site_profile_question, :status => :created, :location => @site_profile_question }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @site_profile_question.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /site_profile_questions/1
  # PUT /site_profile_questions/1.xml
  def update
    @site_profile_question = SiteProfileQuestion.find(params[:id])

    respond_to do |format|
      if @site_profile_question.update_attributes(params[:site_profile_question])
        flash[:notice] = 'Profile Question was successfully updated.'
        format.html { redirect_to(site_admin_site_profile_questions_path) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @site_profile_question.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /site_profile_questions/1
  # DELETE /site_profile_questions/1.xml
  def destroy
    @site_profile_question = SiteProfileQuestion.find(params[:id])
    @site_profile_question.destroy

    respond_to do |format|
      format.html { redirect_to(site_admin_site_profile_questions_url) }
      format.xml  { head :ok }
    end
  end
end
