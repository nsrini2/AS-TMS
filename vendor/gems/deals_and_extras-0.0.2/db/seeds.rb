# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ :name => 'Chicago' }, { :name => 'Copenhagen' }])
#   Mayor.create(:name => 'Daley', :city => cities.first)

# states and provinces
[
  [ "Alabama", "AL" ], 
  [ "Alaska", "AK" ], 
  [ "Arizona", "AZ" ], 
  [ "Arkansas", "AR" ], 
  [ "California", "CA" ], 
  [ "Colorado", "CO" ], 
  [ "Connecticut", "CT" ], 
  [ "Delaware", "DE" ], 
  [ "District Of Columbia", "DC" ], 
  [ "Florida", "FL" ], 
  [ "Georgia", "GA" ], 
  [ "Hawaii", "HI" ], 
  [ "Idaho", "ID" ], 
  [ "Illinois", "IL" ], 
  [ "Indiana", "IN" ], 
  [ "Iowa", "IA" ], 
  [ "Kansas", "KS" ], 
  [ "Kentucky", "KY" ], 
  [ "Louisiana", "LA" ], 
  [ "Maine", "ME" ], 
  [ "Maryland", "MD" ], 
  [ "Massachusetts", "MA" ], 
  [ "Michigan", "MI" ], 
  [ "Minnesota", "MN" ], 
  [ "Mississippi", "MS" ], 
  [ "Missouri", "MO" ], 
  [ "Montana", "MT" ], 
  [ "Nebraska", "NE" ], 
  [ "Nevada", "NV" ], 
  [ "New Hampshire", "NH" ], 
  [ "New Jersey", "NJ" ], 
  [ "New Mexico", "NM" ], 
  [ "New York", "NY" ], 
  [ "North Carolina", "NC" ], 
  [ "North Dakota", "ND" ], 
  [ "Ohio", "OH" ], 
  [ "Oklahoma", "OK" ], 
  [ "Oregon", "OR" ], 
  [ "Pennsylvania", "PA" ], 
  [ "Rhode Island", "RI" ], 
  [ "South Carolina", "SC" ], 
  [ "South Dakota", "SD" ], 
  [ "Tennessee", "TN" ], 
  [ "Texas", "TX" ], 
  [ "Utah", "UT" ], 
  [ "Vermont", "VT" ], 
  [ "Virginia", "VA" ], 
  [ "Washington", "WA" ], 
  [ "West Virginia", "WV" ], 
  [ "Wisconsin", "WI" ], 
  [ "Wyoming", "WY" ],
  ["Alberta", "AB"],
  ["British Columbia", "BC"],
  ["Manitoba", "MB"],
  ["New Brunswick", "NB"],
  ["Newfoundland", "NL"],
  ["Nova Scotia", "NS"],
  ["Northwest Territory", "NT"],
  ["Nunavut", "NU"],
  ["Ontario", "ON"],
  ["Prince Edward Island", "PE"],
  ["Quebec", "QC"],
  ["Saskatchewan", "SK"],
  ["Yukon Territory", "YT"]
].each do |s|
  StateProvince.create(:abbreviation => s[1], :state => s[0])
end

# [
#   'Hotel Only',
#   'Air Only',
#   'Car Rental Only',
#   'Extras Only',
#   'Package Air + Hotel',
#   'Package Air + Hotel + Car Rental',
#   'Package Air + Hotel + Car Rental + Extras'
# ]
["Deals", "Activities & Tours", "Events", "Attractions", "Ground Transportation"].each do |p|
  OfferType.create(:offer_type => p)
end

[
  'Hotel',
  'Car',
  'Air',
  'Tour',
  'Show Ticket',
  'Theme Park'
].each do |t|
  SupplierType.create(:supplier_type => t)
end

[
  'Sabre Enterprise Data Warehouse',
  'Sabre Rewards Plus',
  'Deal & Extras'
].each do |t|
  DataSource.create(:data_source => t)
end

[
  {:login => 'itchy', :password => 'abc123', :email => 'email@sabre.com'},
  {:login => 'smokes', :password => 'holey' , :email => 'email2@sabre.com'}
].each do |t|
  User.create(t)
end

[
  "price",
  "awesomeness",
  "hospitality",
  "location"
].each do |d|
  RatingCategory.create({:rating_category => d})
end

[
 "IATA Airport/City Code",
 "Area",
 "City",
 "Place"
].each do |t|
  LocationType.create({:location_type => t})
end

# process the example xml
Supplier.new_from_xml(open(File.dirname(__FILE__) + '/example.xml').read, DataSource.find_by_data_source("Sabre Enterprise Data Warehouse"))
Offer.new_from_xml(open(File.dirname(__FILE__) + '/example.xml').read)

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

# process the first few locations
#p "Updating Locations"
#Location.find([1,2,3,4,5]).each do |l|
#  l.update_latlon
#  p l
#end