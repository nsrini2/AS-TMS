class SponsorAccount < ActiveRecord::Base
  has_many :sponsors, :class_name => "Profile"
  has_many :groups

  def group_slots_remaining
    self.groups_allowed - self.groups.size
  end

end