class StateProvince < ActiveRecord::Base

  has_many :suppliers

  def self.OPTIONIZE
    self.all.collect{|s| [s.state, s.id] }
  end

end