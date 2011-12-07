require 'hotel_xml'
module Cubeless

  @@hotel_xml_details = HotelXml::AutoIndexedFile.new(Config[:shared_data_path]+"hotel_xml/hotelfeed.details.en.xml",HotelXml::IdAttributeIndexBuilder)
  def self.hotel_xml
    @@hotel_xml_details.index
  end

end