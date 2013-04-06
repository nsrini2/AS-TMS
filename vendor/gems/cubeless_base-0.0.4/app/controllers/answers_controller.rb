class AnswersController < ApplicationController
  before_filter :set_answer, :except => [:vote_best_answer]
  deny_access_for :show  => :sponsor_member

  def new
    if for_new
      @question_summary.update_author_viewed_at(current_profile)
      @question_referral=QuestionReferral.find(:conditions => ["question_id=?",@question_summary.id])
      Rails.logger.info("Niranjana Answer: #{@question_referral.name}")
      @current_owner=@question_referral.referred_to_name
      if @current_owner && @current_owner.is_a?(Group)
         @group=@current_owner
         find_booth_details
         render :layout => 'sponsored_group_manage_submenu'
       end
      redirect_to question_path(@question_summary) if !@question_summary.is_open?
    else
      redirect_to questions_explorations_path
    end
  end

  def show
    # This should really be @answer.question but I have no confidence in that given us overwriting find in Question
    @question = Question.find_by_id(@answer.question_id) 
    redirect_to question_path(@question)
  end

  def create
    @answer = Answer.new(params[:answer])
    @answer.question_id = params[:question_id]
    @answer.profile = current_profile
    if @answer.save
      redirect_to question_path(params[:question_id])
    else
      add_to_errors @answer
      for_new
      render :action => 'new'
    end
  end

  def for_new
    @question_summary = Question.find_by_id(params[:question_id])
    @answer_summaries = @question_summary.answers.order(answer_filters[:order]).paginate(:page => params[:page]) if @question_summary
    rescue ActiveRecord::RecordNotFound
      false
  end

  def vote_best_answer
    @answer = Answer.find(params[:answer_id])
    @question = Question.unscoped.find(params[:question_id])
    if @question.authored_by?(current_profile) && !@answer.authored_by?(current_profile)
      Answer.transaction do
        @answer.mark_best_answer
      end
    end
    respond_to do |format|
      format.html { redirect_to question_path(@question) }
      format.json { render :text => @answer.to_json }
    end
  end

  def edit
    if is_editable?(@answer)
      respond_to do |format|
        format.js { render(:partial => 'answer_edit_popup', :layout => '/layouts/popup') }
      end
    end
  end

  def update
    if is_editable?(@answer)
      respond_to do |format|
        format.json {
          if @answer.update_attributes(params[:answer])
            render :text => @answer.to_json
          else
            add_to_errors(@answer)
            render :text => { :errors => flash[:errors] }.to_json
            flash[:errors] = nil
          end
        }
      end
    end
  end

  def destroy
    @answer.destroy if current_profile.has_role?(Role::ShadyAdmin)

    respond_to do |format|
      format.json {
        render :text => @answer.to_json
      }
    end
  end

  private

  def set_answer
    @answer = Answer.find_by_id(params[:id])
  end

 def find_booth_details
    @group = Group.find(params[:group_id])
    @group_links = @group.group_links.all
     max_id = Group.count_by_sql("select min(profile_id) from (select profile_id from group_memberships where group_id = #{@group.id} order by profile_id desc limit 200) as x")
    @booth_members = @group.members.all(:conditions => "profiles.id >= #{rand(max_id)+1}", :limit => 20).to_a.sort! { |a,b| rand(3)-1 }
    @group_blog_tags=TagCloud.tagcloudize(@group.blog.booth_tags.map{|x|x.name + " "})
    if @group_blog_tags.count > 0
      @group_blog_tags.sort!{|a,b|a[:count]<=>b[:count]}
      @minTagOccurs=@group_blog_tags.first[:count]
      @maxTagOccurs=@group_blog_tags.last[:count]
    end
   end

end
