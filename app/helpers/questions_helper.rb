require_cubeless_engine_file :helper, :questions_helper

module QuestionsHelper
  def link_to_watch_for(question)
    if question.is_being_watched_by_current_user?
      content_tag(:span, 'following', :class => "clicked")
    else
      content_tag(:span, link_to("follow", create_bookmarks_path(:question_id => question.id)), :class => 'watch')
    end
  end
end