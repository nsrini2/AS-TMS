class GroupInvitationRequest < GroupInvitationBase

  belongs_to :group
  belongs_to :sender, :class_name => 'Profile', :foreign_key => 'sender_id'

  def validate
    if group.is_member?(sender)
      errors.add_to_base("You're already a member of this group!")
    elsif sender.has_requested_invitation?(group)
      errors.add_to_base("You have already requested an invitation to this group!")
    elsif sender.has_received_invitation?(group)
      errors.add_to_base("You have already been invited to this group!")
    end
  end

  def accept
    GroupInvitation.create(:group => self.group, :sender => self.group.owner, :receiver => self.sender)
    self.destroy
  end

end