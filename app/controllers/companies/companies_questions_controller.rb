class Companies::QuestionsController < ApplicationController
  before_filter :current_company, :set_selected_tab
  layout "_company_tabs"
  
  def index
    # current_page = question_filters[:page][:current].to_i
    # current_page = 1 unless current_page > 0
    # 
    # page_size = question_filters[:page][:size].to_i
    
    @question_summaries = Question.company_questions(@company.id, question_filters)
    # paged_question_summaries = PagingEnumerator.new(page_size, question_summaries.size, false, current_page, 1) 
    # paged_question_summaries.results = question_summaries[(current_page-1)*page_size..(current_page*page_size)-1]
    # @question_summaries = paged_question_summariesct
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
    # redirect_to new_question_answer_path(:question_id => @question_summary.id) if @question_summary.is_open? and @answer_summaries.size==0
  end
  
  def new
    # for some reason I have to restart Rails for this change to take affect - is this because I am 'freedom punching?'
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