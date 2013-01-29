class Favorite < ActiveRecord::Base  
  belongs_to :user
  belongs_to :offer
  
  validates_uniqueness_of :user_id, :scope => :offer_id

  scope :active, joins(:offer) & Offer.active
end