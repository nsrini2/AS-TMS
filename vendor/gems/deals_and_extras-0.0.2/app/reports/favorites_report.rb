require 'open-uri'
require 'prawn'

class FavoritesReport < Prawn::Document

  def do_title title = nil, by = nil, phone = nil, website = nil, agency = nil
    title = "AgentStream Deals + Extras" if title.blank?
    
    line_2 = []
    line_2 << "Created by: #{by}" unless by.blank?
    line_2 << agency unless agency.blank?
    line_2 = line_2.join(" from ")

    text title, :size => 28, :style => :bold
    text line_2
    text "Phone: #{phone}" unless phone.blank?
    text "Website: #{website}" unless website.blank?
    move_down 25
    stroke_horizontal_rule
    move_down 25
  end

  def to_pdf offers, title = nil, by = nil, phone = nil, website = nil, agency = nil
    
    num = 1
    do_title title, by, phone, website, agency

    pages = (offers.length / 2.0).ceil
    draw_text "Page #{(num / 2.0).ceil} of #{pages}", :at => [500, bounds.absolute_bottom], :size => 11

    offers.each do |offer|
      if num % 2 == 1 && num != 1
        start_new_page
        do_title title, by, phone, website, agency
        
        draw_text "Page #{(num / 2.0).ceil} of #{pages}", :at => [500, bounds.absolute_bottom], :size => 11
      end
      
      if(offer.kind_of? Favorite)
        text "Offer ##{num} #{offer.custom_title.nil? ? offer.offer.short_description : offer.custom_title}", :size => 16, :style => :bold
        text "#{offer.offer.suppliers.first.supplier_name}", :size => 14
        text "#{offer.offer.title_location}", :size => 14
        move_down 8
        # NO DESCRIPTION IN FAVORITES PDF
        # text offer.offer.description, :size => 12
        # move_down 8
        
        # Do add dates
        if offer.offer.offer_type.offer_type.to_s[/deal/i]
          text "Book by #{offer.offer.sell_discontinue_date.inspect}"
          move_down 8
        end
        
        # image open(URI.parse offer.offer.static_map(190, 96))        
        image open(URI.parse offer.offer.static_map(375, 193))
        move_down 25
      elsif(offer.kind_of? Offer)
        text offer.suppliers.first.supplier_name, :size => 15
        move_down 5
        text offer.short_description, :size => 10
        move_down 5
        text offer.description
        move_down 5
        text "#{offer.title_location}"
        move_down 5
        # Do add dates
        if offer.offer_type.offer_type.to_s[/deal/i]
          text "Book by #{offer.sell_discontinue_date.inspect}"
          move_down 5
        end
        # image open(URI.parse offer.static_map(190, 96))
        image open(URI.parse offer.static_map(375, 193))
        move_down 25
      end
      stroke_horizontal_rule if num % 2 != 0 && num != offers.length
      move_down 40
      num = num + 1
    end

    render
  end

end