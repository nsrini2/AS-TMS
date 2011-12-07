class Numeric

  def to_rad
    self*Math::PI/180
  end

  def to_deg
    self*180/Math::PI
  end

end

class GeoUtil

  @@earth_radius_mi = 3963.19  # must be a float for precision

  def self.bounds_from_hash(params,sw_lat_key,sw_lng_key,ne_lat_key,ne_lng_key)
    bounds_from_params(params[sw_lat_key],params[sw_lng_key],params[ne_lat_key],params[ne_lng_key])
  end

  def self.bounds_from_params(sw_lat,sw_lng,ne_lat,ne_lng)
    GeoKit::Bounds.new(GeoKit::LatLng.new(sw_lat.to_f,sw_lng.to_f),GeoKit::LatLng.new(ne_lat.to_f,ne_lng.to_f))
  end

  # dist/bearing formulas from http://www.movable-type.co.uk/scripts/latlong.html

  def self.box_around_latlng(lat,lng,dist,earth_radius=@@earth_radius_mi)
    half_dist = dist/2.0  # must be a float for precision
    [[lat_for_dist_bearing(lat,half_dist,0),lng_for_dist_bearing(lat,lng,half_dist,270)],
    [lat_for_dist_bearing(lat,half_dist,180),lng_for_dist_bearing(lat,lng,half_dist,90)]]
  end

  def self.box_sql(bbox,lat_name='latitude',lng_name='longitude')
    "#{lat_name}<=#{bbox[0][0]} and #{lat_name}>=#{bbox[1][0]} and #{lng_name}>=#{bbox[0][1]} and #{lng_name}<=#{bbox[1][1]}"
  end

  def self.model_mod_find_around!(lat,lng,dist,args)
    ModelUtil.add_conditions!(args,GeoUtil.box_sql(GeoUtil.box_around_latlng(lat,lng,dist)))
  end

  # optimizes GeoKit to use indexes first to narrow the scope
  def self.opt_mappable_find_within!(dist,args)
    hash = ModelUtil.get_options!(args)
    lat,lng = hash[:origin]
    model_mod_find_around!(lat,lng,dist,args)
  end

  def self.geocode_mapquest(options)
    geo_xml = '<?xml version="1.0" encoding="ISO-8859-1"?><Geocode Version="1">'
    geo_xml << "<Address><AdminArea1>#{options[:country] if options[:country]}</AdminArea1><AdminArea3>#{options[:state] if options[:state]}</AdminArea3><AdminArea5>#{options[:city] if options[:city]}</AdminArea5>"
    geo_xml << "<PostalCode>#{options[:zip] if options[:zip]}</PostalCode><Street>#{options[:street] if options[:street]}</Street></Address>"
    geo_xml << '<AutoGeocodeCovSwitch><Name>mqgauto</Name><MaxMatches>1</MaxMatches></AutoGeocodeCovSwitch><Authentication Version="2"><Password>'
    geo_xml << "#{Config.require(:mapquest_password)}</Password><ClientId>#{Config.require(:mapquest_client_id)}</ClientId></Authentication></Geocode>"

    res = ''
    ProxyUtil.net_http.start('geocode.access.mapquest.com', 80) { |http|
      res = http.request_post("/mq/mqserver.dll?e=5", geo_xml)
    }
    return res.body
  end

  private

  def self.lat_for_dist_bearing(lat,dist,bearing,earth_radius=@@earth_radius_mi)
    lat_rad = lat.to_rad
    dR = dist/earth_radius
    Math.asin(Math.sin(lat_rad)*Math.cos(dR) + Math.cos(lat_rad)*Math.sin(dR)*Math.cos(bearing.to_rad)).to_deg
  end

  def self.lng_for_dist_bearing(lat,lng,dist,bearing,earth_radius=@@earth_radius_mi)
    lat_rad = lat.to_rad
    lng_rad = lng.to_rad
    dR = dist/earth_radius
    result = (lng_rad + Math.atan2(Math.sin(bearing.to_rad)*Math.sin(dR)*Math.cos(lat_rad),Math.cos(dR)-Math.sin(lat_rad)*Math.sin(lat_rad))).to_deg
    result+=360 if result<-180
    result-=360 if result>180
    result
  end

end

