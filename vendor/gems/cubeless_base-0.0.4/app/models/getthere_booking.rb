class GetthereBooking < ActiveRecord::Base

  xss_terminate :except => [:xml]
  validates_presence_of :ord_key, :profile_id, :xml, :start_time, :end_time
  belongs_to :profile

  def past?
    end_time < Time.now
  end

  def self.delete_past_bookings
    GetthereBooking.delete_all "end_time < now()"
  end

  def add_pois(poi_list)
    poi_list.pois << poi_list_hotels(property_ids,poi_list)
    poi_list.save!
  end

  def poi_list_hotels(property_ids, poi_list)
    hotels = []
    property_ids.split(", ").each do |property|
      property = property.chop if ("*" == property.last)
      poi = Poi.find_by_external_id(property) || CubelessHotelXML.new(Cubeless.hotel_xml.get_xml_element(property.to_i)).create_poi
      poi.update_last_updated(poi_list.owner_id) if poi.last_updated_by.nil?
      hotels << poi if poi.save
    end
    return hotels
  end
  
  def self.find_by_keywords(query, options)
    SemanticMatcher.default.search_getthere_bookings(query, options.merge!({:direct_query => true}))
  end

  class CubelessHotelXML

    def initialize element
      @element = element
    end

    def create_poi
      poi = Poi.new build_attributes_from_xml
      poi.imported = true
      poi
    end

    def find_property_id
      attr_value hotel_node, "PropertyID"
    end

    def find_name
      attr_value hotel_node, "Name"
    end

    def find_address
      attr_value address_node, "Street1"
    end

    def find_city
      attr_value address_node, "City"
    end

    def find_state
      attr_value address_node, "StateCode"
    end

    def find_zip
      attr_value address_node, "PostalCode"
    end

    def find_country
      attr_value address_node, "CountryCode"
    end

    def find_lat
      attr_value geo_code_node, "Latitude"
    end

    def find_lng
      attr_value geo_code_node, "Longitude"
    end

    def find_photo_url
      attr_value find_first("/Hotel/MultiMediaObjects/Image[@Type='Thumbnail']"), "URL"
    end

    def generate_loc_name
      "#{find_address}, #{find_city}, #{find_state || find_country}"
    end

    def lat_lng
      [find_lat,find_lng]
    end

    private

    def hotel_node
      find_first("/Hotel")
    end

    def address_node
      find_first("/Hotel/Address")
    end

    def geo_code_node
      find_first("/Hotel/HotelDetails/GeoCode")
    end

    def attr_value node, attr_name
      node.attribute(attr_name).value if node && node.attribute(attr_name)
    end

    def find_first xpath
      begin
        REXML::XPath.first(@element, xpath)
      rescue
      end
    end

    def build_attributes_from_xml
      {
        :external_id => find_property_id, :poi_type => Config[:get_there_hotel_type], :name => find_name,
        :loc_name => generate_loc_name, :loc_address1 => find_address, :loc_city => find_city,
        :loc_state => find_state, :loc_zip => find_zip, :loc_country => find_country, :loc_lat => find_lat,
        :loc_lng => find_lng, :photo_url => find_photo_url
      }
    end
  end
  
  protected
  def after_save
    SemanticMatcher.default.getthere_booking_updated(self)
  end
  def after_destroy
    SemanticMatcher.default.getthere_booking_deleted(self)
  end
end