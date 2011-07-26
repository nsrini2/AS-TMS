require_cubeless_engine_file(:controller, :questions_controller)

class QuestionsController
  
  before_filter :check_for_company_question, :only => [:show]
  
  def new
    # for some reason I have to restart Rails for this change to take affect - is this because I am 'freedom punching?'
    @question = Question.new(params[:question])
    respond_to do |format|
      format.js { render(:template => 'questions/new', :layout=> 'layouts/_popup') }
      format.html { render :template => 'questions/new', :layout=> false }
      # format.html { render :layout => false }
    end
  end
  
  def create
    if params["status"] 
      return create_from_hub 
    end
    
    @question = Question.new(params[:question])
    if @question.save
      Bookmark.create(:profile => current_profile, :question_id => @question.id)
      @question = Question.find_summary(@question.id)
      
      # SSJ this is a hand of to the attributes hash so we can access it in the .to_json
      # NOTE: we need to decide where to send prople after asking a question - where they asked (below) or similar questions (below.below) 
      @question[:redirect_path] = questions_explorations_path
      # @question[:redirect_path] = @question.similar_questions.size.zero? ? questions_explorations_path : similar_questions_question_path(@question)
      @question.instance_eval do 
        def similar_questions_path
          self.respond_to?(:redirect_path) ? self.redirect_path : ""
        end
      end  
    end
    
    respond_to do |format|
      format.json {
        if @question.errors.size > 0
          render(:text => { :errors => @question.errors.full_messages }.to_json)
          flash[:errors] = nil
        else
          add_to_notices "Question successfully asked"
          render(:text => @question.to_json(:methods => :similar_questions_path ) )
        end  
      }
      format.html {
        if @question.errors.empty?          
          flash[:errors] = nil
          redirect_to @question[:redirect_path]
        else
          add_to_errors @question
          render :template => 'questions/new', :layout=> false
        end
      }
    end       
  end
  
  protected
  def check_for_company_question
    @question = Question.unscoped(params[:id])
    if @question.company?
      redirect_to companies_question_path(@question) and return
    end
  end

  
  private
    def create_from_hub
      begin   
        @question = Question.new
        @question.profile = current_profile
        @question.question = params["status"]["body"]
        @question.category = params["status"]["question_category"]
        @question.open_until = Time.now.advance(:days => 30)
    
        # TODO: Handle errors
        if @question.save!
          Bookmark.create!(:profile => current_profile, :question_id => @question.id)
      
          render :text => {:errors => [] }.to_json
        end
    
      rescue
        Rails.logger.fatal $!
        render :text => {:errors => @question.errors }.to_json
      end
    end  
end