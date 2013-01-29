class SupplierType < ActiveRecord::Base
  
  has_many :suppliers
  
  def self.OPTIONIZE
    self.all.collect do |s|
      [s.supplier_type, s.id]
    end
  end
  
end