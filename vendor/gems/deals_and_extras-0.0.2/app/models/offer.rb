require 'rubygems'
require 'hpricot'

class Offer < ActiveRecord::Base
  xss_terminate :except => [:raw_xml]


  @t = self.arel_table
  
  has_many :reviews
  has_many :reviewers, :class_name => 'User'

  has_many :favorites
  belongs_to :offer_type
  belongs_to :data_source
  has_and_belongs_to_many :suppliers
  has_and_belongs_to_many :locations

  has_many :favorites
  has_many :users, :through => :favorites

  scope :has_supplier, lambda{ |supplier|
    joins(:suppliers).where("suppliers.id = ?", supplier.id) if supplier.kind_of?(Supplier)
    joins(:suppliers).where("suppliers.id = ?", supplier) if supplier.kind_of?(String) || supplier.kind_of?(Integer)
  }
  
  scope :active, lambda{
    now = Date.current
    # Give one day lee way on expiration
    where(@t[:sell_discontinue_date].gteq(now.advance(:days => -1)).and(@t[:sell_effective_date].lteq(now)))
  }

  scope :data_source, lambda{ |data_source|
    where('data_source_id = ?', data_source.id)
  }

  scope :not_updated_since, lambda{ |time|
    where('updated_at < ?', time)
  }

  scope :not_approved, where(:is_approved => false)
  scope :not_deleted, where(:is_deleted => false)
  scope :pending, where(:is_approved => false)
  scope :approved, where(:is_approved => true)

  #default_scope :order => 'description'

  #default_scope where(:is_approved => true).where(:is_deleted => false)
  
  before_save :cache_supplier_name
  def cache_supplier_name
    self.cached_supplier_name = suppliers.first.supplier_name rescue nil
  end

  def self.new_from_xml(xml_string)        
    # Create Suppliers first
    # MM2: I don't think we need this...
    # e = OfferType.find_by_offer_type('hotel')
    d_and_e_xml = DataSource.find_by_data_source('Sabre Enterprise Data Warehouse')

    # First create the suppliers
    Supplier.new_from_xml(xml_string.dup, d_and_e_xml)
    
    
    offer_type = OfferType.find_by_offer_type("Deals");
    ##
    # Sets the time for which all deals that have not been updated since this
    #   are considered stale and are removed
    ##
    expire_time = Time.now
    sleep 1
    
    offers = []

    doc = Hpricot(xml_string)

    # (doc/"datarow").each do |row|
    (doc/"row").each do |row|
      date_format = '%m/%d/%Y'
      
      sell_effective_date = Date.strptime((row/'startdate').first().innerHTML, date_format) rescue nil
      sell_discontinue_date = Date.strptime((row/'enddate').first().innerHTML, date_format) rescue nil
      description = (row/'dcadtext').first().innerHTML rescue nil
      supplier_external_reference_id = (row/'propertyid').first().innerHTML rescue nil

      next if sell_effective_date.nil? || sell_discontinue_date.nil? || supplier_external_reference_id.nil? || description.nil?

      supplier = Supplier.find_by_supplier_external_reference_id(supplier_external_reference_id)

      property_id = (row/'propertyid').first().innerHTML rescue nil
      property_name = (row/'propertyname').first().innerHTML.downcase rescue nil
      chain_code = (row/'chaincode').first().innerHTML rescue nil
      address_1 = (row/'address1_txt').first().innerHTML rescue nil
      city_name = (row/'city_nm').first().innerHTML rescue nil
      state_province_cd = (row/'state_province_cd').first().innerHTML rescue nil
      country_cd = (row/'country_cd').first().innerHTML rescue nil

      hash_description = description.gsub(/\s/,"")

      hash_id = Offer.offer_hash(property_id, property_name, chain_code, hash_description, sell_effective_date, sell_discontinue_date, address_1, city_name, state_province_cd, country_cd)

      ##
      # If the offer is new a new one is initialized
      # If the offer exists then the offer information is updated with the data
      #   contained in the xml overwriting the current data
      # If an offer in the system is not in the xml it's set to deleted
      ##
      offer = Offer.find_or_initialize_by_hash_id(hash_id)

      airport_code = (row/'airport').first().innerHTML rescue nil

      location = Location.find_or_initialize_by_description(supplier.full_address)
      offer.locations.push location
      unless location.id.nil?
        location.city = supplier.city
        location.save
      end

      if(airport_code)
        offer.locations.push Location.find_or_create_by_description(airport_code)
      end

      offer.property_id = property_id
      offer.sell_effective_date = sell_effective_date
      offer.sell_discontinue_date = sell_discontinue_date
      offer.description = description
      offer.suppliers.push(supplier)
      offer.offer_type = offer_type if offer_type.instance_of?(OfferType)
      offer.data_source = d_and_e_xml
      
      # FOR NOW
      # offer.is_approved = true
      # offer.approved_at = Time.now
      # NOT ANYMORE
      offer.is_approved = false if offer.new_record?
      offer.approved_at = nil if offer.new_record?

      # Capture the raw xml
      offer.raw_xml = row.to_s


      ##
      # If the offer hasn't actually changed update the updated_at time stamp
      #   so that the clean up step doesn't removed an offer that was contained
      #   in the xml
      ##
      offer.touch

      offer.save
      offers.push offer
    end



    # Find the offers that come from the xml data wharehouse that not have been
    #   updated or added since the current time, basically an offer that
    #   wasn't in the xml just imported


    # MM2: The requirement is a little different than expected
    # In the beginning, the idea was the the xml was the FULL SET of offers
    # Now, the xml is the set of NEW offers. Should not be deleting old offers.
    
    # i = 0
    # Offer.data_source(d_and_e_xml).not_updated_since(expire_time).each do |offer|
    #   i = i + 1
    #   p "deleting #{offer} #{i}"
    #   offer.is_deleted = true;
    #   offer.save
    # end

    offers
  end

  def self.filter(params)
    here params
    
    # TO DO:
    #   See about moving these out to scopes
    
    args = []
    predicates = []

    arg = []
    
    o = Offer
    
    # predicate = params[:filter_dates].collect do |date|
    # 
    #   month, year = date.split("/")
    #   args.push(month).push(year).push(year)
    #   "((? BETWEEN MONTH(sell_effective_date) AND MONTH(sell_discontinue_date)) 
    #    AND (? = YEAR(sell_effective_date) OR ? = YEAR(sell_discontinue_date)))"
    # 
    # end.join(" or ") rescue ""
    # predicates.push("(".concat(predicate).concat(")")) unless predicate == ""
    # args.concat(arg) unless predicate == ""

    arg = []
    predicate = params[:filter_includes].collect do |include_id|
      args.push(include_id)
      "offer_type_id = ?"
    end.join(" or ") rescue ""
    predicates.push("(".concat(predicate).concat(")")) unless predicate == ""
    args.concat(arg) unless predicate == ""

    if (!params[:filter_origin].nil? && params[:filter_origin] != '') && (!params[:filter_destination].nil? && !params[:filter_destination] != '')
      args.push(params[:filter_origin])
      args.push(params[:filter_destination])
      predicates.push("(".concat("locations.city = ? OR locations.city = ?").concat(")"))
    else
      if params[:filter_origin] != '' && !params[:filter_origin].nil?
        args.push(params[:filter_origin])
        predicates.push("(".concat("locations.city = ?").concat(")"))
      end

      if params[:filter_destination] != '' && !params[:filter_destination].nil?
        args.push(params[:filter_destination])
        predicates.push("(".concat("locations.city = ?").concat(")"))
      end
    end

    predicate = predicates.join(" AND ")

    query = self

    if params['date_filter']
      #start_date = Date.civil(params['date_filter']['start_date(1i)'].to_i, params['date_filter']['start_date(2i)'].to_i, 1) rescue nil
      #end_date = Date.civil(params['date_filter']['end_date(1i)'].to_i, params['date_filter']['end_date(2i)'].to_i, Offer.days_in_month(params['date_filter']['end_date(1i)'].to_i, params['date_filter']['end_date(2i)'].to_i)) rescue nil
      date_format = '%m/%d/%Y'
      start_date = Date.strptime(params['date_filter']['start_date'], date_format) rescue nil
      end_date = Date.strptime(params['date_filter']['end_date'], date_format) rescue nil
    end

    # unless start_date.nil?
    #   query = query.where('sell_effective_date > ?', start_date)
    # end
    # unless end_date.nil?
    #   query = query.where('sell_discontinue_date < ?', end_date)
    # end
    if start_date && end_date
      query = query.where('(sell_effective_date < ? AND sell_discontinue_date > ?) OR (sell_effective_date < ? AND sell_discontinue_date > ?)', start_date, start_date, end_date, end_date)
    elsif start_date
      query = query.where('sell_effective_date < ?', start_date).where('sell_discontinue_date > ?', start_date)
    elsif end_date
      query = query.where('sell_effective_date < ?', end_date).where('sell_discontinue_date > ?', end_date)
    end



    if !params['query'].nil? && params['query'] != ''
      query = query.where("offers.description LIKE ?", "%#{params[:query]}%");
    end

    if(params['supplier'])
      params['supplier'].split(',').each do |supplier_id|
        query = query.has_supplier(supplier_id)
      end
    end

    # Setup order
    query = case params[:sort_by]
              when "rating"
                query.order("cached_positive_review_percentage DESC") 
              when "rating_count"
                query.order("cached_reviews_count DESC")
              when "name_r"
                query.order("cached_supplier_name DESC")
              else
                query.order("cached_supplier_name ASC")
            end
    
    # query = query.joins(:suppliers).order("suppliers.supplier_name")

    query = query

    #self.active.where(predicate, *args).paginate(:page => params[:page], :per_page => params[:per_page])
    # query.where(predicate, *args).joins(:locations).approved.not_deleted.uniq.paginate(:page => params[:page], :per_page => params[:per_page])
    query.where(predicate, *args).joins(:locations).approved.not_deleted.active.paginate(:page => params[:page], :per_page => 20).uniq
  end

  def self.days_in_month(year, month)
    (Date.new(year, 12, 31) << (12-month)).day
  end

  def self.offer_hash(*vars)
    Digest::MD5.hexdigest(vars.collect{ |v| v.to_s }.join).to_s
  end

  def location
    locations[0]
  end
  
  def location=(loc)
    locations = []
    locations.push(loc)
  end

  def location_id
    locations[0].id unless locations.length < 1
  end
  
  def title_location
    t = []
    
    if location.international?
      t << location.description
    else
      t << location.city
      t << location.state_province.state rescue nil
      t << location.country.country rescue nil
    end
    t.reject{ |t| t.blank? }.join(", ")
  end

  def short_description
    d = normalize_string read_attribute('short_description')
    
    if d.blank?
      d = description
    end
    
    # d.to_s.split("\n").first.to_s[0..40]
    d.to_s.split("\n").first.to_s.truncate(40, :separator => ' ', :omission => ' ...')
  end
  
  def short_description_html
    htmlize_string short_description
  end

  def description
    normalize_string read_attribute('description')
  end
  
  def description_html    
    # Fix the hotel booking formats
    htmlize_string(description).gsub(/(HOD\S* \d+ Nt\d+)/i) { |h| h.to_s.upcase.sub(/\s/,"-").sub(" ","") }
  end
  
  def normalize_string(string)
    # Remove leading * and . and any * and spaces
    string = string.to_s.gsub(/^(\*|\.)/,"").gsub("*","").strip
    
    # Convert any - to ^^^^^. Hacky I know.
    string = string.gsub("-","^^^^^")
    
    # Split into lines and title case
    string = string.split("\n").collect{ |s| s.strip.titlecase }.join("\n")
    
    # Put the hyphens back in
    string = string.gsub("^^^^^", "-")
    
    string
  end
  
  def htmlize_string(string)
    string.split("\n").join("<br/>")
  end

  def location_id=(location_id)
    self.locations = []
    l = Location.find(location_id)
    locations.push(l)
    self.save
  end

  def offer
    self.suppliers.first
  end
  
  def booking_info
    if book_by_sabre?
      "HOD#{property_id}"
    else
      ""
    end
  end
  
  def book_by_sabre?
    !property_id.blank?
  end
  
  def book_by_phone?
    
  end
  
  def book_by_url?
    !url.blank?
  end

  def static_map(width = 375, height = 193)
    if location.international?
      return map_coming_soon_path
    end
    
    map_mode = Setting.map_mode
    lat = location.latitude
    long = location.longitude
    if lat.nil? || long.nil?
      lat = "39.743943"
      long = "-105.020089"
    end
    if(map_mode == 'google')
      %{http://maps.google.com/maps/api/staticmap?center=#{lat},#{long}&zoom=12&size=#{width}x#{height}&maptype=roadmap&sensor=false}
    elsif(map_mode =='map_quest')
      %{http://www.mapquestapi.com/staticmap/v3/getmap?key=#{Setting.map_quest_api_key}&size=#{width},#{height}&zoom=7&center=#{lat},#{long}&pois=purple,#{lat},#{long},0,0}
    end
  end
  
  # MapQuest only
  def dynamic_map(width = 375, height = 193)
    if location.international?
      return map_coming_soon
    end
    
    lat = location.latitude
    long = location.longitude
    if lat.nil? || long.nil?
      lat = "39.743943"
      long = "-105.020089"
    end

    dom_id = "offer_#{self.id}_map"
    js_var = "offer_#{self.id}_js"
    

    map_options = <<-EOJS
      var options={ 
        elt:document.getElementById('#{dom_id}'),       /*ID of element on the page where you want the map added*/
        zoom:10,                                  /*initial zoom level of the map*/
        latLng:{lat:#{lat}, lng:#{long}},  /*center of map in latitude/longitude */
        mtype:'map'                               /*map type (map)*/
      };
    EOJS
    
    map_controls = <<-EOJS
      #{js_var}.addControl(
        new MQA.SmallZoom(),
        new MQA.MapCornerPlacement(MQA.MapCorner.TOP_LEFT, new MQA.Size(5,5))
      );
    EOJS
    
    map_poi = <<-EOJS
      var poi=new MQA.Poi({lat:#{lat}, lng:#{long}});
      // poi.setInfoTitleHTML('');
      // poi.setInfoContentHTML('');
      #{js_var}.addShape(poi);
    EOJS
    
    js = <<-EOJS
      <script type="text/javascript">
        MQA.withModule('smallzoom', function() {
          #{map_options}
        
          #{js_var} = new MQA.TileMap(options);
        
          #{map_controls}
        
          #{map_poi}
        });
      </script>
    EOJS
    
    map_div = <<-EOH
      <div id='#{dom_id}' style='width:#{width}px; height:#{height}px;' class="small_map"></div>
    EOH

    js + map_div
  end
  
  def map_coming_soon_path
    "http://www.agentstream.com/images/de/map_coming_soon.png"
  end
  def map_coming_soon
    "<div class=\"small_map\"><img src=\"#{map_coming_soon_path}\" alt=\"Map coming soon.\" /></div>"
  end
  
  def rehash!        
     xml_string = self.raw_xml

     return if xml_string.blank?

     doc = Hpricot(xml_string)

     # (doc/"datarow").each do |row|
     (doc/"row").each do |row|
       date_format = '%m/%d/%Y'

       sell_effective_date = Date.strptime((row/'startdate').first().innerHTML, date_format) rescue nil
       sell_discontinue_date = Date.strptime((row/'enddate').first().innerHTML, date_format) rescue nil
       description = (row/'dcadtext').first().innerHTML rescue nil
       supplier_external_reference_id = (row/'propertyid').first().innerHTML rescue nil

       next if sell_effective_date.nil? || sell_discontinue_date.nil? || supplier_external_reference_id.nil? || description.nil?

       property_id = (row/'propertyid').first().innerHTML rescue nil
       property_name = (row/'propertyname').first().innerHTML.downcase rescue nil
       chain_code = (row/'chaincode').first().innerHTML rescue nil
       address_1 = (row/'address1_txt').first().innerHTML rescue nil
       city_name = (row/'city_nm').first().innerHTML rescue nil
       state_province_cd = (row/'state_province_cd').first().innerHTML rescue nil
       country_cd = (row/'country_cd').first().innerHTML rescue nil

       hash_description = description.gsub(/\s/,"")

       hash_id = Offer.offer_hash(property_id, property_name, chain_code, hash_description, sell_effective_date, sell_discontinue_date, address_1, city_name, state_province_cd, country_cd)

       update_attribute(:hash_id, hash_id)
     end
   end
  
  def approve
    self.update_attributes(:is_approved => true, :approved_at => Time.now)
  end
  def delete
    self.update_attributes(:is_deleted => true, :deleted_at => Time.now)
  end
  
  def percentage
    rs = reviews.verified
    return 0 if rs.count <= 0
    ups = rs.select{ |r| r.rating }.count
    Rails.logger.info "---------------- #{rs.count.to_f}"
    Rails.logger.info "---------------- #{ups.to_f}"
    ((ups.to_f/rs.count.to_f)*100).to_i
  end

end