module GroupOwned
  def get_group_recipients(memberships)
    subscriptions = memberships.select { |membership| membership.wants_notification_for?(self) && !self.authored_by?(membership.member) }
    subscriptions.collect { |subscription| subscription.member.email }
  end
end