class Notifiers::Group < Notifier
  
  def new_comment_on_group_post(comment)
    @recipients = comment.owner.profile.email
    @subject = "#{comment.owner.group.name} just received a new reply to your group talk post."
    self.body = { :comment => comment }
  end
  
end