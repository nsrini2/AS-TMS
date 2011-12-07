# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ :name => 'Chicago' }, { :name => 'Copenhagen' }])
#   Mayor.create(:name => 'Daley', :city => cities.first)

# process the example xml
Supplier.new_from_xml(open('./db/example.xml').read, DataSource.find_by_data_source("Sabre Enterprise Data Warehouse"))
Offer.new_from_xml(open('./db/example.xml').read)

# Set the settings for the app
Setting.google_api_key = ''
Setting.map_quest_api_key = 'Fmjtd%7Cluu22q61nl%2C8s%3Do5-h62a1'
Setting.map_mode = 'map_quest'

[
  {
    :email => "s@s.com",
    :password => '123123',
    :password_confirmation => '123123',
    :supplier => Supplier.first
  }
].each do |s|
  SupplierUser.create(s)
end