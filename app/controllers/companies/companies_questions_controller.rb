class Companies::QuestionsController < ApplicationController
  before_filter :current_company, :set_selected_tab
  layout "_company_tabs"
  
  def index
    @question_summaries = Question.company_questions(current_company.id, question_filters)
    @new_question_link = @template.link_to("Ask a Question", new_companies_question_path)
    render :template => '/questions/index'
  end
  
  def show
    begin
      @question_summary = Question.find_summary(params[:id], :include => [:best_answer], :auth => true, :unscoped => true)
    rescue
      redirect_to(companies_questions_path) and return if @question_summary.blank?
    end
    @question_summary.update_author_viewed_at current_profile
    @answer_summaries = @question_summary.answers.find(:all,answer_filters(:summary => true))
    @best_answer = @question_summary.best_answer
  end
  
  def new
    @question = Question.new(params[:question])
  end
  
  def create
    @question = Question.new(params[:question])  
    @question.open_until = 1.month.from_now
    @question.company_id = @company.id
    if @question.save
      flash[:notice] = "Company Question Created!"
      redirect_to :action => :index
    else
      add_to_errors @question
      render :action => :new
    end    
  end
  
  def edit
    respond_to do |format|
      format.js { render(:partial => '/questions/question_edit_popup', :layout => 'layouts/_popup', :locals => { :question => Question.unscoped(params[:id]) }) }
    end
  end

  def update
    @question = Question.unscoped(params[:question_id])
    if is_editable?(@question)
      @question.open_until = params[:question][:open_until]
      if @question.answers_count < 1 || current_profile.has_role?(Role::ShadyAdmin)
        @question.category = params[:question][:category]
        @question.question = params[:question][:question]
      end
      respond_to do |format|
        format.json {
          if @question.save
            render :text => @question.to_json
          else
            add_to_errors(@question)
            render :text => { :errors => flash[:errors] }.to_json
            flash[:errors] = nil
          end
        }
      end
    end
  end
  
  def destroy
    @question = Question.unscoped(params[:id])
    @question.destroy if is_editable?(@question)
    
    respond_to do |format|
      format.json {
        render :text => @question.to_json
      }
    end
  end

private
  def set_selected_tab
    @company_question_tab_selected = "selected"
  end
  
end