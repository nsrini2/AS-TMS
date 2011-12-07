class GroupInvitation < GroupInvitationBase

  belongs_to :group
  belongs_to :sender, :class_name => 'Profile', :foreign_key => 'sender_id'
  belongs_to :receiver, :class_name => 'Profile', :foreign_key => 'receiver_id'

  def validate
    if receiver.nil?
      errors.add_to_base("Hum? We can't seem to find that person in the system. Please type a name and then select the appropriate person from the list.")
    elsif sender.id == receiver.id
      errors.add_to_base("You can't invite yourself to a group you're already a member of! Try inviting someone else.")
    elsif group.is_member?(receiver)
      errors.add_to_base("You can't invite a member to a group they're already a member of! Try inviting someone else.")
    elsif receiver.has_received_invitation?(group)
      errors.add_to_base("#{receiver.full_name} has already been invited to this group! Try sending it to someone else.")
    elsif receiver.is_sponsored?
      errors.add_to_base("Sorry, #{receiver.full_name} is a Sponsored Member and may not be invited to join groups.")
    end
  end
  
  def self.destroy_by_group_and_receiver(group_id, receiver_id)
    # if invitation = find(:first, :conditions => ["group_id = ? and receiver_id = ?", group_id, receiver_id])
    if invitation = where(:group_id => group_id).where(:receiver_id => receiver_id).first
      invitation.destroy
    end
  end

end