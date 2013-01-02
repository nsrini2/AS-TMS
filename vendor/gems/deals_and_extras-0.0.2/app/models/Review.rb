# renamed with lowercase -- this comment to for git to reload!
class Review < ActiveRecord::Base

  belongs_to :rating_category
  belongs_to :offer
  belongs_to :user
  belongs_to :temp_user

  validates_presence_of :rating_category_id, :offer_id

  validates_uniqueness_of :user_id, :scope => :offer_id, :message => 'You have reviewed this deal already', :allow_nil => true
  validates_uniqueness_of :temp_user_id, :scope => :offer_id, :message => 'You have reviewed this deal already', :allow_nil => true

  scope :temp, where(Review.arel_table[:temp_user_id].not_eq(nil))
  scope :verified, where((Review.arel_table[:user_id].not_eq(nil)))
  scope :not_verified, where((Review.arel_table[:user_id].eq(nil)))
  
  after_save :cache_offer_reviews_count
  after_save :cache_offer_positive_review_percentage

  def cache_offer_reviews_count
    self.offer.update_attribute(:cached_reviews_count, self.offer.reviews(true).count) if self.offer
  end
  
  def cache_offer_positive_review_percentage
    self.offer.update_attribute(:cached_positive_review_percentage, self.offer.percentage) if self.offer
  end

end