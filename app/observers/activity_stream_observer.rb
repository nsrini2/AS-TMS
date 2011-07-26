require_cubeless_engine_file :observer, :activity_stream_observer
class ActivityStreamObserver < ActiveRecord::Observer

  private
  
  def skip_logging?(model)
    case model
      when Question
        return model.company_question?
      when Answer  
        return model.question.company_question?
      when BlogPost  
        return model.blog.owner_type=='Group' && model.blog.owner.is_private? 
      when Comment
        return model.owner.is_a?(GroupPost) || (model.owner.is_a?(BlogPost) && model.owner.blog.owner.is_a?(Group) && model.owner.blog.owner.is_private?)
    end
    false
  end

end