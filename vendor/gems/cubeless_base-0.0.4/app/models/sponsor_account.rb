class SponsorAccount < ActiveRecord::Base
  has_many :sponsors, :class_name => "Profile"
  has_many :groups, :dependent => :destroy
  has_one  :showcase_category_image, :as => :owner, :dependent => :destroy
  validates_numericality_of :groups_allowed, :only_integer => true, :greater_than_or_equal_to => 0, :message => " Please enter a positive integer value for no. of booths allowed"
  validates_presence_of :name

  def group_slots_remaining
    self.groups_allowed - self.groups.size
  end

end
