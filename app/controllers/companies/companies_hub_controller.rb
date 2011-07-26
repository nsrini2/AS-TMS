class Companies::HubController < ApplicationController
  before_filter :current_company, :set_question, :set_seleted_tab
  layout "_company_tabs"
  
  def show
    @aside_question_header = "Question Reffered to me"
    @aside_questions = current_profile.questions_referred_to_me
    if @aside_questions.size == 0 
      @aside_question_header = "Latest Question"
      @aside_questions = [Question.company_questions(current_company.id).last]
    end  
    set_events
  end
  
  def create_question
    if @question.save
      flash[:notice] = "Company question created."
      @question = Question.new()
    else  
      add_to_errors @question
    end  
    redirect_to :action => :show
  end

private  
  def set_question
    @question = Question.new(params[:question])
    @question.open_until = 1.month.from_now
    @question.company_id = @company.id
  end
  
  def set_events
    @events = CompanyStreamEvent.find_summary(:all, :conditions => ["company_stream_events.company_id = #{current_company.id}" ], :limit => 15)
  end
  
  def set_seleted_tab
    @company_hub_tab_selected = "Selected"
  end
  
end
