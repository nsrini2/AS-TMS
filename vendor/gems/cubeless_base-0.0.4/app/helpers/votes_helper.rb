module VotesHelper
  # helpful voting
  # def votes_current_state_for(owner)
  #   partial = Vote.current_user_has_voted?(owner) ? 'stats' : 'vote'
  #   render :partial => "votes/#{partial}", :locals => {:model => model}
  # end
  # 
  # def voting_eligibility_for(owner)
  #   if owner.authored_by?(current_profile) || !logged_in?
  #     render :partial => 'votes/stats', :locals => {:owner => owner}
  #   else
  #     votes_current_state_for owner
  #   end
  # end

  def link_to_vote_helpful(owner)
    link_to(image_tag("/images/de/thumbs_up_small.png", :alt => "Helpful", :title => "Helpful"), 
            { :controller => :votes, :action => :helpful, :owner_id => owner.id, :owner_type => owner.class}, 
            { :class => 'vote helpful', :method => :post })
  end

  def link_to_vote_not_helpful(owner)
    # url = not_helpful_question_answer_vote_path(@question_summary || model.question, model)
    # link_to(image_tag("/images/de/thumbs_down_small.png", :alt => "Not Helpful", :title => "Not Helpful"), url, :class => 'vote not_helpful')
    link_to(image_tag("/images/de/thumbs_down_small.png", :alt => "Helpful", :title => "Helpful"), 
            { :controller => :votes, :action => :not_helpful, :owner_id => owner.id, :owner_type => owner.class}, 
            { :class => 'vote helpful', :method => :post })
  end

  # def render_voting_mechanism_for(owner)
  #   render :partial => 'votes/show', :locals => {:owner => owner}
  # end

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
            label << "<br />" << link_to_vote_best(question, answer)
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

  def link_to_vote_best(question, answer)
    link_to(image_tag("/images/voteBest.png", 
                      :size => '17x21', 
                      :alt => "Best answer?"), 
                      question_answer_vote_best_answer_path(question, answer, :method => :post), :class => 'best')
  end

end