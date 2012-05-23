module VotesHelper
  # helpful voting
  def votes_current_state_for(model)
    partial = model.current_user_has_voted? ? 'stats' : 'vote'
    render :partial => "votes/#{partial}", :locals => {:model => model}
  end

  def voting_eligibility_for(model)
    if model.authored_by?(current_profile) || !logged_in?
      render :partial => 'votes/stats', :locals => {:model => model}
    else
      votes_current_state_for model
    end
  end

  def link_to_vote_helpful(model)
    url = helpful_question_answer_vote_path(@question_summary || model.question, model)
    # url = "/"
    link_to(image_tag("/images/helpfulYes.png", :alt => "Helpful", :size => '48x20', :title => "Helpful"), url, :class => 'vote helpful')
  end

  def link_to_vote_not_helpful(model)
    url = not_helpful_question_answer_vote_path(@question_summary || model.question, model)
     # url = "/"
    link_to(image_tag("/images/helpfulNo.png", :alt => "Not Helpful", :size => '48x20', :title => "Not Helpful"), url, :class => 'vote not_helpful')
  end

  def render_voting_mechanism_for(model)
    @model = model
    render :partial => 'votes/show'
  end

  # best answer voting
  def is_best_and_closed(answer, question)
     answer.is_best? && question.is_closed? 
  end
    
  def is_best_and_open(answer, question)
     answer.is_best? && question.is_open? 
  end
  
  def best_label_display(answer, question, label)
        best = Answer.find(:all, 
             :conditions => ['question_id =? and best_answer is true', question.id ])    

        if( (question.is_open? || question.is_closed?) )
            label << link_to_vote_best(answer)
        else
            label = nil
        end
  end  

  def voting_is_allowed_for(answer, question)  
    if(question.authored_by?(current_profile) && !answer.authored_by?(current_profile) )
        best = Answer.find(:all, 
             :conditions => ['question_id =? and best_answer is true', question.id ])    
        best[0].nil? && question.is_closed? || 
        ( !answer.is_best_answer_selected? && question.is_open?)  
    end
  end

  def voting_is_allowed(answer, question, &block)
    block_text = capture(&block)
    block_text if voting_is_allowed_for(answer, question)
  end

  def link_to_vote_best(answer)
    # link_to(image_tag("/images/voteBest.png", 
    #                   :size => '17x21', 
    #                   :alt => "Best answer?"), 
    #                   vote_best_answer_answers_path(:id => answer.id), :class => 'best')
    ""
  end

end