class Companies::AnswersController < ApplicationController
  before_filter :current_company, :set_selected_tab
  layout "_company_tabs"
  
  def index
    render :text => "app/controllers/companies/companies_answers_controller.rb::index"
  end
  
  def show
    
  end
  
  def new
    # render :text => "#{params.inspect} <br />\n companies_answers, new <br />\n/companies/questions/#{params[:question_id]}/answers/new(.:format)"
    if for_new
      @question_summary.update_author_viewed_at(current_profile) 
      redirect_to companies_question_path(@question_summary) if !@question_summary.is_open? 
    else
      redirect_to companies_questions_path
    end 
  end
  
  def create
    @answer = Answer.new(params[:answer])
    @answer.question_id = params[:question_id]
    @answer.profile = current_profile
    if @answer.save
      redirect_to companies_question_path(params[:question_id])
    else
      add_to_errors @answer
      for_new
      render :action => 'new'
    end
  end
  
  def edit
    
  end
  
  def update
    
  end
  
  def destroy
    
  end

private
  
  def set_selected_tab
    @company_question_tab_selected = "Selected"
  end

## Probably should be in model -- also in answers_controller  
  def for_new
    @question_summary = Question.find_summary(:first, :conditions => ['questions.id=?',params[:question_id]], :auth => true, :unscoped => true)
    @answer_summaries = @question_summary.answers.find(:all, answer_filters(:summary => true)) if @question_summary
  end
  
end