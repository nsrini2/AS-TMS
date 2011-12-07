module ApplicationHelper
  
  def de_image(offer)
    path = "/images/de/deal.gif"
    
    case offer.offer_type.offer_type.to_s.downcase
      when /event/: path = "/images/de/event.gif"
      when /activities/: path = "/images/de/activities.gif"
      when /ground/: path = "/images/de/car.gif"
      when /other/: path = "/images/de/other.gif"
      when /attract/: path = "/images/de/attraction.gif"
    end
      
    
    image_tag path, :alt => offer.offer_type.offer_type.to_s
  end
  
  def de_badge_image(offer)
    image_class = ["deal_percentage"]
    container_class = ["seal_container"]
    
    if offer.reviews.empty?
      path = "/images/de/first.png"
      alt = "Be the First to Rate!"
      container_class << "first_seal"
    else
      path = "/images/de/seals.png"
      alt = "Deal"
      container_class << "seal_#{offer.percentage.to_s}"
    end
    
    # img = image_tag path, :alt => alt, :class => image_class.join(" ")
    img = ""
    content_tag "div", img, :class => container_class.join(" "), :id => "offer_#{offer.id}_seal_container"

  end
  
  def de_thumbs(offer)
    img1 = de_thumbs_up_img(offer)
    img2 = de_thumbs_down_img(offer)
    img1 + img2
  end
  
  def de_thumbs_up_img(offer)
    image_tag "/images/de/thumbs_up_small.png", :alt => offer.id, :class => "deal_thumbs_up"
  end
  def de_thumbs_down_img(offer)
    image_tag "/images/de/thumbs_down_small.png", :alt => offer.id, :class => "deal_thumbs_down"
  end
  
  def render_404(exception = nil)
    if exception
      logger.info "Rendering 404 with exception: #{exception.message}"
    end

    respond_to do |format|
      format.html { render :file => "#{Rails.root}/public/404.html", :status => :not_found }
      format.xml  { head :not_found }
      format.any  { head :not_found }
    end
  end
  
  # image_to
  # based of the Rails 3.0 button_to
  # Changes:
  #   1) Add image_path params
  #   2) Make submit input an image
  def image_to(image_path, name, options = {}, html_options = {})
    html_options = html_options.stringify_keys
    convert_boolean_attributes!(html_options, %w( disabled ))

    method_tag = ''
    if (method = html_options.delete('method')) && %w{put delete}.include?(method.to_s)
      method_tag = tag('input', :type => 'hidden', :name => '_method', :value => method.to_s)
    end

    form_method = method.to_s == 'get' ? 'get' : 'post'

    remote = html_options.delete('remote')

    request_token_tag = ''
    if form_method == 'post' && protect_against_forgery?
      request_token_tag = tag(:input, :type => "hidden", :name => request_forgery_protection_token.to_s, :value => form_authenticity_token)
    end

    url = options.is_a?(String) ? options : self.url_for(options)
    name ||= url

    html_options = convert_options_to_data_attributes(options, html_options)

    # html_options.merge!("type" => "submit", "value" => name)
    html_options.merge!("type" => "image", "src" => image_path, "alt" => name, "value" => name)

    ("<form method=\"#{form_method}\" action=\"#{html_escape(url)}\" #{"data-remote=\"true\"" if remote} class=\"button_to\"><div>" +
      method_tag + tag("input", html_options) + request_token_tag + "</div></form>").html_safe
  end
  
  def add_to_folder_image_path
    # "/images/de/DE_AddtoFolderPlus_final2_89X25.gif"
    "/images/de/add_to_folder.png"
  end
  
  def remove_from_folder_image_path
    # "/images/de/DE_AddtoFolderPlus_final2_89X25.gif"
    "/images/de/remove_from_folder.png"
  end
  
  def booking_info_image_path
    # "/images/de/DE_BookingInfodollarsign_final_89X25.gif"
    "/images/de/booking_info.png"
  end
  
end
