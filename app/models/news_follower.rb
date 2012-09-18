class NewsFollower < ActiveRecord::Base
  include InheritsFrom
  inherits_from :profile
  
  validates :profile_id, :presence => true
  
  def latest_visit
    updated_at
  end
  
  def self.profiles
    NewsFollower.includes(:profile).all
  end
  
  def self.following?(profile)
    !!find_by_profile_id(profile.id)
  end
  
  def self.visit(profile)
    follower = find_by_profile_id(profile.id)
    follower.touch if follower
  end
end
