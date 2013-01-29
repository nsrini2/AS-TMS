class OfferType < ActiveRecord::Base

  has_many :offers
  
  def html_checked
    true unless self.offer_type.match(/^deals$/i)
  end

  def self.OPTIONIZE
    self.all.collect{|t| [t.offer_type, t.id] }
  end

end