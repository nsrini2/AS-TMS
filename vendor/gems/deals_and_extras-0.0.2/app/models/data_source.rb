class DataSource < ActiveRecord::Base
  
  has_many :suppliers
  
  def self.OPTIONIZE
    self.all.collect do |s|
      [s.data_source, s.id]
    end
  end
  
end