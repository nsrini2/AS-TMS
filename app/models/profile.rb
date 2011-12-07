require_cubeless_engine_file :model, :profile

class Profile
  belongs_to :company
  include Notifications::Profile
  
  scope :with_karma_points_greater_than, lambda { |points|
    where(Profile.arel_table[:karma_points].gt(points))
  }
  
  def company?
    !company.nil?
  end
  
  def karma_rank
    Profile.active.with_karma_points_greater_than(self.karma_points).count + 1
  end
  
end