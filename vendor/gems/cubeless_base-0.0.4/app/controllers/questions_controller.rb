class QuestionsController < ApplicationController
  deny_access_for [:index, :new, :create, :similar_questions, :close, :update_close, :destroy] => :sponsor_member

  def index
    @question_summaries = Question.find(:all,question_filters)
    respond_to do |format|
      format.html
    end
  end

  def edit
    respond_to do |format|
      format.js { render(:partial => 'question_edit_popup', :layout => '/layouts/popup', :locals => { :question => Question.find(params[:id]) }) }
    end
  end

  def update
    @question = Question.unscoped.find_by_id(params[:id])
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

  def show
    # @question_summary = Question.find(params[:id], :include => [:best_answer], :auth => true).first
    # SSJ not sure what the :auth => true param does exactly...
    # debugger
    @question_summary = Question.where(:id => params[:id]).includes(:best_answer).first
    @question_summary.update_author_viewed_at current_profile
    @answer_summaries = @question_summary.answers.order(answer_filters[:order]).paginate(:page => params[:page])
    @best_answer = @question_summary.best_answer
    redirect_to new_question_answer_path(:question_id => @question_summary.id) if @question_summary.is_open? and @answer_summaries.size==0
  end

  def new
    @question = Question.new(params[:question])
  end

  def create
    @question = Question.new(params[:question])
    if @question.save
      Bookmark.create(:profile => current_profile, :question_id => @question.id)
      @question = Question.find_summary(@question.id)
      redirect_to @question.similar_questions.size.zero? ? questions_asked_profile_path(@question.profile) : similar_questions_question_path(@question)
    else
      add_to_errors @question
      render :action => "new"
    end
  end

  def similar_questions
    @question = Question.find_summary(params[:id])
    @sim_question_summaries = @question.similar_questions(:page => default_paging)
  end

  def close
    question = Question.find(params[:id])
    if question.editable_by?(current_profile)
      question.close
      @profile = current_profile
    end
    respond_to do |format|
      format.html { redirect_to :back }
      format.json { render :text => question.to_json }
    end
  end

  def destroy
    @question = Question.find(params[:id])
    @question.destroy if is_editable?(@question)
    
    respond_to do |format|
      format.json {
        render :text => @question.to_json
      }
    end
  end

  def remove
    question_id = params[:id]
    owner_type, owner_id = params[:owner_type], params[:owner_id]
    owner = find_by_type_and_id(owner_type, owner_id)
    instance_variable_set("@#{owner_type.downcase}", owner)
    QuestionReferral.clear_all_by_question_id_and_owner(question_id,owner)
    QuestionProfileExcludeMatch.find_or_create_by_question_id_and_profile_id(question_id,owner_id)
    if owner.is_a?(Profile)
      QuestionProfileMatch.destroy_all(['question_id=? and profile_id=?', question_id,owner_id])
      questions = owner.matched_questions(:page => {:size => 5, :current => params[:questions_page]})
    end
    respond_to do |format|
      format.html { redirect_to :back }
    end
  end

end