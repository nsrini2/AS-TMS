require_cubeless_engine_file :model, :profile

class Profile
  belongs_to :company
  include Notifications::Profile
  after_save :update_site_visits
  
  scope :with_karma_points_greater_than, lambda { |points|
    where(Profile.arel_table[:karma_points].gt(points))
  }
  
  def registration_field(site_registration_field_id)
    profile_registration_field = ProfileRegistrationField.where(:profile_id => self.id).where(:site_registration_field_id => site_registration_field_id)
    profile_registration_field.first.value
    rescue
      "NONE"
  end
  
  def company?
    !company.nil?
  end
  
  def karma_rank
    Profile.active.with_karma_points_greater_than(self.karma_points).count + 1
  end
  
  def update_site_visits
    SiteVisit.track(self)
  end
  
end