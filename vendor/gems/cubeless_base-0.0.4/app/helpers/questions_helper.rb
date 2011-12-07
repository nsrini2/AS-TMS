module QuestionsHelper
  include VotesHelper
  include QuestionReferralsHelper
  include AnswersHelper

  def avatar_content_for_question(should_show)
    yield if should_show[:avatar]
  end

  def link_to_answers(question)
    link_to(pluralize(question.num_answers, "answer"), question_path(question))
  end

  def home_link_to_answers(question, answers_count)
    link_to(pluralize(answers_count, "new answer"), question_path(question))
  end

  def open_until_or_closed_on_for(question)
    (question.is_open? ? 'Open Until ' : 'Closed On ') + content_tag(:span, short_date(question.open_until), :id => "open_until_#{question.id}")
  end

  def link_to_question(question,&block)
    question_text = block ? yield(question.question) : question.question
    link_to(replace_newline_with_br(question_text), question_path(question), :class => 'question_text')
  end

  def link_to_question_truncated(question, length, truncate_string = "...")
    link_to_question(question) { |question| truncate(question, :length => length, :omission => truncate_string) }
  end

  def question_link_content_for(should_show, question)
    if should_show[:linked_question]
      link_to_question_truncated(question, 264, '... more')
    else
      content_tag(:span, truncated_auto_link(question.question, 90, {:class => 'answer_link'}), :class => 'question_text')
    end
  end

  def render_question_category(question)
    "category: #{link_to question.category.downcase, questions_explorations_path(:filter_category => question.category)} - " unless question.category.blank?
  end

  def rank_content_for(question)
    yield if question.match_rank && Config[:rank_enabled]
  end

  def update_open_until_content_for(question)
    yield if question.authored_by?(current_profile) and question.is_open?
  end

  def question_render_toggle_list(show_list=nil)
    default = {:avatar => true, :answer => true,
    :answer_inline => false, :close => false,
    :remove => false, :remove_watch => false, :shady => true, :refer => true,
    :referred_by => false, :referred_to => false,
    :referred_to_groups => true, :linked_question => true}
    default.merge!(show_list) if show_list
    default
  end

  def remove_watched_question_button_content(options={}, &block)
    yield if options[:remove_watch]
  end

  def answer_button_content(options={}, &block)
    yield if options[:answer] && !options[:answer_inline]
  end

  def refer_button_content(options={}, &block)
      yield if options[:refer] && logged_in? unless hide_for_sponsor
  end

  def remove_match_and_referral_button_content(options={}, &block)
    yield if options[:remove]
  end

  def close_button_content(options={}, &block)
    yield if options[:close] unless hide_for_sponsor
  end

  def shady_content(options={})
    return (options[:shady] and (logged_in? and (current_profile.has_role?(Role::ShadyAdmin) || current_profile != @profile))) unless block_given?
    yield if options[:shady] and (logged_in? and (current_profile.has_role?(Role::ShadyAdmin) || current_profile != @profile))
  end

  def link_to_answer(question)
    return unless question.is_open?
    link_to('Answer', new_question_answer_path(:question_id => question.id), :class => "button little")
  end

  def link_to_close(question)
    return unless question.authored_by?(current_profile) || current_profile.has_role?(Role::ShadyAdmin)
    link_to('Close', close_question_path(:id => question.id), :class => "button little light close")
  end

  def empty_questions_image_for(questions)
    return unless questions.size.zero? && ((params[:filter_scope] == 'all')||(!params[:filter_scope]))
    if current_profile == @profile
      link_to(image_tag("/images/askQuestions.gif", :id => "askQuestions", :alt => "Ask a Question"), new_question_path)
    else
      link_to(image_tag("/images/noQuestions.gif", :id => "askQuestions", :alt => ""), questions_explorations_path)
    end
  end

  def my_question_content_for(questions)
    yield if questions.size > 0
  end

  def link_to_edit_question(question)
    link_to('edit', edit_question_path(:id => question.id), :class => 'modal edit')
  end

  def truncated_auto_link(text, size, options={})
    replace_newline_with_br(auto_link(text, :all, options) do |text|
            truncate(text, :length => size)
            end)
  end

  def open_question_actions_content(question, &block)
    yield question if question.is_open?
  end

  def closed_question_content(question)
    logger.warn("Closed_question_content is depricated! -- Please use question.is_open?")
    # yield unless question.is_open?
  end

  def link_to_watch_for(question)
    if question.is_being_watched_by_current_user?
      content_tag(:span, 'watching', :class => "clicked")
    else
      content_tag(:span, link_to("watch this", create_bookmarks_path(:question_id => question.id)), :class => 'watch')
    end
  end

  def link_to_remove_match_and_referral_for(object, question)
    link_to('Remove', remove_question_path(:id => question.id, :owner_type => object.class.name, :owner_id => object.id), :class => 'button little light')
  end

  def render_referred_questions_for(object, referred_questions, can_remove_question=true)
    render( :partial => 'questions/questions',
              :locals => {:domain => 'referred_questions', :questions => referred_questions,
              :questions_for => object, :model => object.class.name, :show => {:referred_by => true, :referred_to_groups => false, :remove => can_remove_question}} )
  end

  def link_to_delete_question(question)
    if question.authored_by?(current_profile) && question.num_answers == 0 || current_profile.has_role?(Role::ShadyAdmin)
      link_to("delete", question_path(question), :class => 'modal delete')
    end
  end

  def question_author_or_shady_admin_content(question)
    return (question.authored_by?(current_profile) && question.is_open?) || current_profile.has_role?(Role::ShadyAdmin) unless block_given?
    yield if (question.authored_by?(current_profile) && question.is_open?) || current_profile.has_role?(Role::ShadyAdmin)
  end

end