require_cubeless_engine_file(:controller, :questions_controller)

class QuestionsController
  alias :original_create :create
  
  def create    
    if !params["status"]["body"]
      original_create and return 
    end
    
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