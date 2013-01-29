class RepliesController < ApplicationController
  before_filter :set_reply
  deny_access_for :show => :sponsor_member

  def new
    @answer = Answer.find(params[:answer_id])
    if is_editable?(@answer.question)
      respond_to do |format|
        format.js { render(:partial => 'answers/answer_reply_popup', :layout => '/layouts/popup') }
      end
    end
  end

  def edit
    @answer = @reply.answer
    if is_editable?(@answer.question)
      respond_to do |format|
        format.js { render(:partial => 'answers/edit_reply_popup', :layout => '/layouts/popup') }
      end
    end
  end

  def update
    @answer = @reply.answer
    if is_editable?(@answer.question)
      @reply.text = params[:reply][:text]
      respond_to do |format|
        format.json {
          if @reply.save
            render :text => @reply.to_json
          else
            add_to_errors(@reply)
            render :text => { :errors => flash[:errors] }.to_json
            flash[:errors] = nil
          end
        }
      end
    end
  end

  def create
    @answer = Answer.find(params[:answer_id])
    if is_editable?(@answer.question)
      @reply.answer_id = params[:answer_id]
      @reply.text = params[:reply][:text]
      @reply.profile = current_profile
      respond_to do |format|
        format.json {
          if @reply.save
            render :text => @reply.to_json
          else
            add_to_errors(@reply)
            render :text => { :errors => flash[:errors] }.to_json
            flash[:errors] = nil
          end
        }
      end
    end
  end

  def show
    @answer = @reply.answer
    options = answer_filters(:summary => true)
    ModelUtil.add_conditions!(options, ["answers.id=?", @answer.id])
    @question_summary = Question.find_summary(@answer.question_id)
    @answer_summaries = @question_summary.answers.find(:all, options)
    render :template => 'questions/show'
  end

  private

  def set_reply
    @reply = Reply.find_by_id(params[:id]) || Reply.new
  end
end