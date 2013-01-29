class SiteAdmin::SiteQuestionCategoriesController < ApplicationController
  allow_access_for :all => :cubeless_admin

  layout 'site_admin'

  helper :site_question_categories
  
  before_filter :setup_selected_tab
  def setup_selected_tab
    @selected = "question_categories_tab"
  end
  
  before_filter :cancel_button_reset, :only => [:create, :update, :reorder]
  def cancel_button_reset
    redirect_to site_admin_site_question_categories_path and return if params[:reset]
  end
  
  # GET /site_question_categories
  # GET /site_question_categories.xml
  def index
    @site_question_categories = SiteQuestionCategory.find(:all, :order => :position)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @site_question_categories }
    end
  end

  # GET /site_question_categories/1
  # GET /site_question_categories/1.xml
  def show
    @site_question_category = SiteQuestionCategory.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @site_question_category }
    end
  end

  # GET /site_question_categories/new
  # GET /site_question_categories/new.xml
  def new
    @site_question_category = SiteQuestionCategory.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @site_question_category }
    end
  end

  # GET /site_question_categories/1/edit
  def edit
    @site_question_category = SiteQuestionCategory.find(params[:id])
  end
  
  # GET /site_question_categories/edit_order
  def edit_order
    @site_question_category = SiteQuestionCategory.new
    @site_question_categories = SiteQuestionCategory.find(:all)    
  end
  
  # POST /site_question_categories
  def reorder    
    if params[:categories]
      params[:categories].each_pair do |k,v|
        category = SiteQuestionCategory.find(k)
        category.update_attribute(:position, v.to_i)
      end
    end
    
    redirect_to site_admin_site_question_categories_path
  end

  # POST /site_question_categories
  # POST /site_question_categories.xml
  def create
    @site_question_category = SiteQuestionCategory.new(params[:site_question_category])

    respond_to do |format|
      if @site_question_category.save
        flash[:notice] = 'Question Category was successfully created.'
        format.html { redirect_to site_admin_site_question_categories_path }
        format.xml  { render :xml => @site_question_category, :status => :created, :location => @site_question_category }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @site_question_category.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /site_question_categories/1
  # PUT /site_question_categories/1.xml
  def update
    @site_question_category = SiteQuestionCategory.find(params[:id])
    
    # TODO: Move this to a model callback after we update Rails
    # Track the old name
    old_name = @site_question_category.name

    respond_to do |format|
      if @site_question_category.update_attributes(params[:site_question_category])
        
        # TODO: Move this to a model callback after we update Rails
        # TODO: Move this to a batch update process
        # Update all the questions that have this category
        questions = Question.find_all_by_category(old_name)
        questions.each do |q|
          q.update_attribute(:category, @site_question_category.name)
        end
        
        flash[:notice] = 'Question Category was successfully updated.'
        format.html { redirect_to(site_admin_site_question_categories_path) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @site_question_category.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /site_question_categories/1
  # DELETE /site_question_categories/1.xml
  def destroy
    @site_question_category = SiteQuestionCategory.find(params[:id])
    @site_question_category.destroy

    respond_to do |format|
      format.html { redirect_to(site_admin_site_question_categories_url) }
      format.xml  { head :ok }
    end
  end
end
