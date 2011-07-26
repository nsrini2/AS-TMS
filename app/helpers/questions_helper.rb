require_cubeless_engine_file :helper, :questions_helper

module QuestionsHelper
  def link_to_watch_for(question)
    if question.is_being_watched_by_current_user?
      content_tag(:span, 'following', :class => "clicked")
    else
      content_tag(:span, link_to("follow", create_bookmarks_path(:question_id => question.id)), :class => 'watch')
    end
  end
  
  
  # SSJ -- Allow company questions to be found
  def company_or_question_path(question, company=nil)
    company = Company.find(company) if company && company.class != Company
    question = Question.unscoped(question) unless question.class == Question
    if company || question.company?
      companies_question_path(question)
    else  
      question_path(question)
    end  
  end

  def link_to_question(question,company=nil, &block)
    question_text = block ? yield(question.question) : question.question
    link_to(replace_newline_with_br(question_text), company_or_question_path(question, company), :class => 'question_text')
  end

  def link_to_question_truncated(question, length, truncate_string = "...", company=nil)
    link_to_question(question, company) { |question| truncate(question,length,truncate_string) }
  end

  def question_link_content_for(should_show, question)
    if should_show[:linked_question]
      link_to_question_truncated(question, 264, '... more', should_show[:company])
    else
      content_tag(:span, truncated_auto_link(question.question, 90, {:class => 'answer_link'}), :class => 'question_text')
    end
  end

  def render_question_category(question, should_show={})
    unless question.category.blank?
      if should_show[:company]
        link_path = companies_questions_path(:filter_category => question.category) 
      else
        link_path = questions_explorations_path(:filter_category => question.category) 
      end  
      "category: #{link_to question.category.downcase, link_path } - "
    end  
  end
  
  def link_to_answer(question)
    return unless question.is_open?
    if question.company_question? 
      link_path = new_companies_question_answer_path(:question_id => question.id)
    else  
      link_path = new_question_answer_path(:question_id => question.id)
    end 
    link_to('Answer', link_path, :class => "button little") 
  end
  
  def link_to_delete_question(question)
    if question.authored_by?(current_profile) && question.num_answers == 0 || current_profile.has_role?(Role::ShadyAdmin)
      link_to("delete", company_or_question_path(question), :class => 'modal delete') 
    end
  end
  
  def link_to_edit_question(question)
    if question.company_question?
      edit_path = edit_companies_question_path(:id => question.id)
    else
      edit_path = edit_question_path(:id => question.id)
    end
    link_to('edit', edit_path, :class => 'modal edit')
  end
  
  def url_for_update_question(question)
    if question.company_question?
      # SSJ -- I hate this but I was not able to get the routing engine to make a correct route
      "/companies/questions/#{question.id}/update"
    else
      update_question_path(question)
    end
    
  end
  
end