class OfferType < ActiveRecord::Base

  has_many :offers

  def self.OPTIONIZE
    self.all.collect{|t| [t.offer_type, t.id] }
  end

end