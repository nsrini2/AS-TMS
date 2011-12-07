require 'rubygems'
require 'hpricot'

class Supplier < ActiveRecord::Base
  
  has_and_belongs_to_many :offers
  belongs_to :country
  belongs_to :data_source
  belongs_to :supplier_type
  belongs_to :state_province

  default_scope order(:supplier_name)

  scope :distinct_cities, lambda{
    select('DISTINCT city').where('city IS NOT NULL').order('city')
  }

  def self.new_from_xml(xml_string, data_source = nil)    
    doc = Hpricot(xml_string)
    
    # (doc/"datarow").each do |row|
    (doc/"row").each do |row|
      
      supplier_external_reference_id = (row/'propertyid').first().innerHTML rescue nil
      
      next if supplier_external_reference_id.nil?
      
      supplier = self.find_or_initialize_by_supplier_external_reference_id(supplier_external_reference_id)
      
      next unless supplier.new_record?
      
      #supplier.type = 
      supplier.data_source = data_source if data_source.instance_of?(DataSource)
      supplier.supplier_name = (row/'propertyname').first().innerHTML rescue nil
      supplier.address_1 = (row/'address1_txt').first().innerHTML rescue nil
      supplier.address_2 = (row/'address2_txt').first().innerHTML rescue nil
      supplier.address_3 = (row/'address3_txt').first().innerHTML rescue nil
      supplier.city = (row/'city_nm').first().innerHTML rescue nil
      supplier.state_province = StateProvince.find_by_abbreviation((row/'state_province_cd').first().innerHTML.upcase) rescue nil
      #supplier.state_province = 
      supplier.postal_code = (row/'postal_cd').first().innerHTML rescue nil
      #supplier.country = 
      
      supplier.save
    end
    
  end

  def full_address
    address_1      = self.address_1
    address_2      = self.address_2
    address_3      = self.address_3
    city           = self.city
    state_province = self.state_province.state rescue ""
    postal_code    = self.postal_code
    "#{address_1} #{address_2} #{address_3} #{city}, #{state_province} #{postal_code}"
  end

  def self.cities
    cities = []
    self.distinct_cities.each do |c|
      cities.push(c.city)
    end
    cities
  end

  def supplier_name
    read_attribute('supplier_name').titleize
  end

end