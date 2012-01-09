class ProfileAward < ActiveRecord::Base
  include Notifications::ProfileAward
  belongs_to :award
  belongs_to :profile
  
  attr_accessor :karma_points
  
  def karma_points=(value)
    @karma_points = value.to_i
  end   
  
  def validate
    cant_find_match_error = "We couldn't the recipient you were looking for."
    awarded_by_error = "This award must be \"awarded by\" someone."
    karma_point_validator
    errors.add_to_base(cant_find_match_error) unless profile
    errors.add_to_base(awarded_by_error) if awarded_by.blank?
  end
  
  def karma_point_validator
     errors.add_to_base("Karma points must be positive") unless karma_is_positive? 
  end
  
  named_scope :visible, :conditions => { :visible => true }
  named_scope :hidden, :conditions => { :visible => false }
  
  def awarded_on
    self.created_at.strftime("%b %d, %Y")
  end

  def make_default!
    ActiveRecord::Base.connection.update("update profile_awards set is_default=case id when #{self.id} then 1 else 0 end where profile_id=#{self.profile_id}")
  end

  def toggle_visibility!
    self.toggle!(:visible)
  end
  
  def title
    award.title
  end
  
  def remove_default
    self.update_attributes("is_default" => false)
  end
  
  def last_profile_award?
    count = ProfileAward.count_by_sql "select count(1) from profile_awards where profile_id = #{self.profile_id} and visible = true"
    count == 1 && self.visible
  end

  # # is the number positive
   def karma_is_positive?
      (karma_is_numeric? && karma_points.to_i >= 0) ? true : false
   end
   
   def karma_is_numeric?  # validate string or number
      karma_points.to_s.match(/\A[+-]?\d+?(\.\d+)?\Z/) == nil ? false : true
   end
   
   def after_save
       puts "profile.karma_points = #{profile.karma_points} + #{karma_points}"
       profile.karma_points = profile.karma_points + self.karma_points
       profile.save!
   end
end
