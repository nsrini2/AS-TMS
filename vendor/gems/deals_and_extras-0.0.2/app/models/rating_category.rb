class RatingCategory < ActiveRecord::Base
  
  #belongs_to :offer
  has_many :reviews
  
  def self.OPTIONIZE
    self.all.collect{|t| [t.rating_category.capitalize, t.id] }
  end
  
end