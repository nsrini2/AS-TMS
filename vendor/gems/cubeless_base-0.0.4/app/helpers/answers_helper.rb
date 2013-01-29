module AnswersHelper

  def link_to_edit_answer(answer)
    link_to('edit', edit_answer_path(answer), :class => "modal edit") if answer.editable_by?(current_profile)
  end

  def link_to_edit_reply(reply)
    link_to('edit', edit_answer_reply_path(reply.answer, reply), :class => "modal edit_reply") if reply.answer.question.editable_by?(current_profile)
  end

  def truncated_auto_linked_answer_text(answer)
    truncated_auto_link(answer.answer, 90, {:class => 'answer_link'})
  end

  def link_to_reply_to(answer)
    link_to('reply', new_answer_reply_path(answer), :class => "modal new_reply") unless answer.question.is_closed? || answer.reply || answer.authored_by?(current_profile)
  end

  def reply_content_for(answer)
    yield if answer.reply
  end

  def reply_for(answer)
    content_tag(:div, truncated_auto_link(answer.reply.text, 90), :class => 'reply', :id => "reply_#{answer.reply.id}")
  end

  def link_to_delete_answer(answer)
    link_to('delete', answer_path(answer), :class => 'modal delete') if current_profile.has_role?(Role::ShadyAdmin)
  end
end
