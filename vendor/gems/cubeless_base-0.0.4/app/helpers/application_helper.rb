module ApplicationHelper

  include BlogsHelper
  include CommentsHelper
  include ContentHelper
  include FilterSortHelper
  include PhotosHelper
  include AwardsHelper
  include ExplorationsHelper

  DStruct = Struct.new(:mo, :yr, :day)
  def struct_from_date(date)
    date ? DStruct.new(date.strftime('%b'), date.year, date.day) : DStruct.new(nil, nil, nil)
  end

  def action_list_for(links, options={})
    content_tag(:ul, links.compact.inject(""){ |result, link| result << "<li>#{link}</li>" }, :class => "action_list #{options[:class]}", :id => "#{options[:id]}") unless links.empty?
  end

  def sub_menu_for(lis, options={})
    content_tag(:ul, lis.compact.inject(""){ |result, li| result << li }, :class => "action_list sub_nav #{options[:class]}") unless lis.empty?
  end

  def sub_menu_li_for(url, options={})
    sub_menu_link = url.split("?").first
    link_from = request.request_uri.split("?").first
    content_tag(:li, link_to(options[:text], url), :class => ('selected' if link_from == sub_menu_link || options[:selected]) )
  end

  #BEGIN DATE RELATED METHODS

  def smart_date(start_date=nil, end_date=nil)
    sd, ed = struct_from_date(start_date), struct_from_date(end_date)
    yr_text = lambda{|date| "#{', ' + date.yr.to_s if date.yr}"}
    mo_and_day_text = lambda{|date| "#{date.mo} #{date.day}"}
    separator = lambda{|date1,date2,method| " #{'- ' if date1.send(method) && date2.send(method)}"}
    smartdates = mo_and_day_text.call(sd)
    if sd.yr == ed.yr
      if sd.mo == ed.mo
        smartdates << separator.call(sd,ed,"day") << "#{ed.day}" if sd.day != ed.day
      else
        smartdates << separator.call(sd,ed,"day") << mo_and_day_text.call(ed)
      end
      smartdates << yr_text.call(sd)
    else
      smartdates << yr_text.call(sd) << separator.call(sd,ed,"day") << mo_and_day_text.call(ed) << yr_text.call(ed)
    end
    smartdates
  end

  def timeago(time)
    start_date = Time.new
    little_over_a_week = 11520
    delta_minutes = (start_date.to_i - time.to_i).floor / 60
    if delta_minutes.abs < little_over_a_week
      cubeless_distance_of_time_in_words(delta_minutes) + (delta_minutes < 0 ? " from now" : " ago")
    else
      return "on #{short_date(time)}"
    end
  end

  def cubeless_distance_of_time_in_words(minutes)
    [#[max_int (in minutes), phrase] - add as many as necessary
      [1, "less than a minute"],
      [20, "a few minutes"],
      [45, "about half an hour"],
      [90, "about one hour"],
      [1080, pluralize((minutes/60).round, "hour")],
      [1440, "one day"],
      [2880, "about one day"],
      [8640, "a few days"],
      [11520, "about a week"]
    ].each{|x,y| return y if minutes < x}
  end

  def short_date(date)
    date.strftime("%b %d, %Y")
  end

  def mini_date(date)
    date.strftime("%m/%d/%y")
  end
  
  def pretty_datetime(date)
    date.strftime("%b %d, %Y at %I:%M %p")
  end

  def at_time(date)
    date.strftime("@ %I:%M %p")
  end

  def pretty_date(date)
    date.strftime("%A %B %d, %Y")
  end

  def short_time12(date)
    time.strftime("%I:%M")
  end

  def pretty_time12(date)
    date.strftime("%I:%M:%S")
  end

  def short_time24(date)
    time.strftime("%H:%M")
  end

  def pretty_time24(date)
    date.strftime("%H:%M:%S")
  end
  
  def short_time24_tz(date)
    date.strftime("%H:%M %Z")
  end
  
  #END DATE RELATED METHODS

  #IMAGE RELATED METHODS

  def marketing_image_tag(message)
    link_to_if(message.link_to_url, image_tag( marketing_image_path(message), :alt => '', :width => "595", :height => "220"),message.link_to_url) if message
  end

  def marketing_image_path(marketing_message,which=:large)
    marketing_message.image_path.nil? ? marketing_message.marketing_image.public_filename(which) : "/images/marketing_#{marketing_message.image_path}_#{which.to_s}.jpg"
  end

  def replace_flash_now_notice_for(page, msgs=[])
    add_to_notices(msgs)
    return if flash[:notice].blank?
    page[:notice_flash_holder].replace_html :partial => 'application/flash_notice'
  end

  def replace_flash_error_for(page, records_or_msgs=[], target=nil)
    add_to_errors(records_or_msgs)
    return if flash[:errors].blank?
    unless target.nil?
      page[target].replace_html :partial => 'application/overlay_flash_error'
    else
      page[:error_flash_holder].replace_html :partial => 'application/popup_flash_error'
    end
  end

  def link_button_remote(text, options={})
    size = options.delete(:size) || "large"
    color = options.delete(:color) || ""
    style = options.delete(:inline) ? "display: inline;" : ""
    content_tag(:div, link_to(text, options.delete(:url), options.merge!({:class => "#{size} #{color} button", :remote => true})), :style => style)
  end

  def small_link_button_remote(text, options)
    link_button_remote(text, options.merge!(:size => 'little'))
  end

  def submit_button(text, options={})
    size = options.delete(:size) || "large"
    color = options.delete(:color) || ""
    align = options.delete(:align) || "center"
    style_class = options.delete(:class) || "clear"
    style = options.delete(:style) || ""
    d_options = {:align => align, :class => style_class, :style => style}
    d_options.merge!({:id => options[:id]}) if options[:id]
    options[:onclick] = "#{options[:onclick]}"
    content_tag(:div, submit_tag(text, options.merge!(:class => "#{size} #{color} button")), d_options)
  end

  def link_button(text, url, options={})
    size = options.delete(:size) || "large"
    color = options.delete(:color) || ""
    link_to(text, url, options.merge!(:class => "#{size} #{color} button"))
  end

  def small_button(text, url, options={})
    link_button(text, url, options.merge!(:size => 'little'))
  end

  def primary_small_button(text, url, options={})
    small_button(text, url, options)
  end

  def secondary_small_button(text, url, options={})
    small_button(text, url, options.merge!(:color => "light"))
  end

  def highlight_fade_color
    "startcolor:\'#666666\', "
  end

  def replace_newline_with_br(text)
    text.gsub(/\r?\n/,'<br/>')
  end

  def render_abuse(abuseable)
    @abuseable = abuseable
    render :partial => 'abuses/show'
  end

  def render_watch_link(model)
    return if model.is_a?(Group) && model.is_private? && !model.is_member?(current_profile)
    if current_profile.watches.find_by_watchable_type_and_watchable_id(model.class.to_s, model.id)
      "<span class='clicked'>following</span>"
    else
      content_tag(:span, link_to("follow", create_profile_watches_path(current_profile, :type => model.class, :id => model.id)), :class => 'follow')
    end
  end

  def link_for_group_post_delete(post,group)
    if group.editable_by?(current_profile) || post.authored_by?(current_profile) #!H #!O relies on rails2 cache (N-Posts)
      link_to("delete", group_post_path(post), :class => "modal delete")
    end
  end

  def link_to_mark_shady(abuseable)
    link_to('inappropriate', polymorphic_url([abuseable, :abuse], :action => :new, :routing_type => :path), :class => "modal")
  end

  def render_pagination(collection, options={})
    if options[:working]
      render :partial => 'shared/paginate_working', :locals => { :collection => collection, :page_var => options[:page_var], :ajax => options[:ajax]}
    else
      render :partial => 'shared/paginate', :locals => { :collection => collection, :page_var => options[:page_var], :ajax => options[:ajax]}
    end
  end

  #faster pagination http://www.igvita.com/blog/2006/09/10/faster-pagination-in-rails/
  def windowed_pagination_links(pagingEnum, options)
    link_to_current_page = options[:link_to_current_page]
    always_show_anchors = options[:always_show_anchors]
    padding = options[:window_size]

    current_page = pagingEnum.page
    html = ''

    #Calculate the window start and end pages
    padding = padding < 0 ? 0 : padding
    first = pagingEnum.page_exists?(current_page  - padding) ? current_page - padding : 1
    last = pagingEnum.page_exists?(current_page + padding) ? current_page + padding : pagingEnum.last_page

    # Print start page if anchors are enabled
    html << yield(1) if always_show_anchors and not first == 1

    # Print window pages
    first.upto(last) do |page|
      (current_page == page && !link_to_current_page) ? html << page : html << yield(page)
    end

    # Print end page if anchors are enabled
    html << yield(pagingEnum.last_page).to_s if always_show_anchors and not last == pagingEnum.last_page
    html
  end

  def render_widget(widget, draggable=true, collapsible=true)
    render :partial => 'widgets/widget', :locals => { :widget => widget, :draggable => draggable, :collapsible => collapsible }
  end

  def link_for_group_action(group)
    hide_for_sponsor do
      if group.is_member?(current_profile)
        link_to("quit group", quit_group_path(group), :class => 'modal quit_group button little')
      elsif current_profile.has_requested_invitation?(group)
        "<span class='clicked'>request sent</span>"
      elsif !group.is_public? && group.has_members? && !current_profile.has_received_invitation?(group)
        link_to("request invitation", invitation_request_group_invitation_path(group), :class => "request_invite button")
      elsif !group.is_private? || current_profile.has_received_invitation?(group)
        link_to("join", join_group_path(group), :class => "modal join_group button")
      end
    end
  end

  def link_for_booth_action(group)
    hide_for_sponsor do
      if group.is_member?(current_profile)
        link_to("Quit Following", quit_group_path(group), :class => 'modal quit_group button little')
      elsif current_profile.has_requested_invitation?(group)
        "<span class='clicked'>Follow Request Sent</span>"
      elsif !group.is_public? && group.has_members? && !current_profile.has_received_invitation?(group)
        link_to("Request Invite", invitation_request_group_invitation_path(group), :class => "request_invite button")
      elsif !group.is_private? || current_profile.has_received_invitation?(group)
        link_to("Follow", join_group_path(group), :class => "modal join_group button")
      end
    end
  end

  def link_for_group_members_action(group)
    if group.invitation_can_be_accepted_or_sent_by?(current_profile)
      link_to("invite someone", new_group_invitation_path(:group_id => group.id), :class => "modal invite")
    else
      nil # link_for_group_action(group) 
    end
  end

  def link_for_sponsor_group_members_action(group)
    if group.sponsor_group_invitation_can_be_sent_by?(current_profile)
      link_to("invite someone", new_group_invitation_path(:group_id => group.id), :class => "modal invite")
    else
      nil # link_for_group_action(group) 
    end
  end
  
  def link_for_resend_action(group)
    if group.invitation_can_be_accepted_or_sent_by?(current_profile)
      link_to("Resend ALL Invitations", resend_all_group_path(group), :class => "invite_all")
    else
      nil # link_for_group_action(group)
    end
  end

  def link_for_resend_sponsor_group_action(group)
    if group.sponsor_group_invitation_can_be_sent_by?(current_profile)
      link_to("Resend ALL Invitations", resend_all_group_path(group), :class => "invite_all")
    else
      nil # link_for_group_action(group)
    end
  end

  def confirm_popup(message,options={})
    # takes in :no_function, :yes_function, :yes_image, and :no_image options
    # yes_function is what is to be run when yes btn is clicked, no function is for no btn
    # yes_image and no_image are image options for the images in the popup, such as :alt, :size
    options[:no_function] ||= "cClick(); return false;"
    (options[:yes_image] ||= {})[:alt] ||= "Yes"
    (options[:no_image] ||= {})[:alt] ||= "No"
    "showPopup('#{escape_javascript(render(:partial => 'shared/confirm_popup', :locals => {:message => message, :options => options}))}'); return false;"
  end

  def render_close_popup_link(text="close")
    content_tag("div", link_to_function("close", "cClick();"), :class => "close")
  end

  def link_to_author(authored)
    link_to_profile(authored.profile)
  end

  def link_to_profile(profile, show_stars=true)
    fail "Why is profile nil?" unless profile
    if current_profile.is_sponsored?
      profile.first_name
    else  
      link_to_if(profile.visible?, profile.screen_name, profile_path(:id => profile.id), :class => ("karma_level_#{Karma.new(profile.karma_points).recognition_level}" if show_stars))
    end
  end

  def render_karma_icons_for_profile(profile, which=:small)
    return '' unless karma_viewable_content(profile)
    render_karma_icons_for_points(profile.karma_points, which)
  end

  def render_karma_icons_for_points(karma_points, which=:small)
    k = Karma.new(karma_points)
    options = {:title => "User Rank: #{k.title}"}
    options[:title] << " (#{karma_points} karma points)" if karma_viewable_content
    render_karma_icons_for_level(k.recognition_level, which, options)
  end

  @@karma_icon_dims = Hash.new({}).merge!({
    :small => { :width => 11, :height => 10 },
    :large => { :width => 13, :height => 12 }
  })
  def render_karma_icons_for_level(level, which=:small, options={})
    level > 0 ? ("<img src='/images/karma_#{which}.png' alt='' width='#{@@karma_icon_dims[which][:width]}' height='#{@@karma_icon_dims[which][:height]}' />" * level) : ''
  end

  def show_posession_for(text)
    "#{text}'#{'s' unless text.last=='s'}"
  end

  def render_inline_editor_for(object, field, path, options = {})
    editable = options.has_key?(:editable) ? options[:editable] : object.editable_by?(current_profile)
    
    val = object.send(field) || (object.is_a?(Profile) && !editable ? "None Provided" : "")
    val = val.join(', ') if val.is_a?(Array)
    html_options = { :id => options[:id], :class => options[:class] }
    
    if editable
      html_options.merge!({ :class => "#{html_options[:class]} inline_editable #{'tooltip' if options[:tooltip]}", :title => options[:tooltip] })
      data = { :object => object.class.name.underscore, :name => field, :type => options[:type] || 'text', :url => path }
      data.merge!({ :width => options[:width] }) if options[:width]
      data.merge!({ :height => options[:height] }) if options[:height]
      data.merge!({ :placeholder => options[:placeholder] }) if options[:placeholder]
      data.merge!({ :maxlength => options[:maxlength] }) if options[:maxlength]
      val += content_tag(:script, data.to_json, :type => "application/json")
    end
    content_tag( options[:tag] || :p, replace_newline_with_br(editable ? val : auto_link(val, :all)), html_options )
  end

  def link_to_shady_abuse(abuse)
    link_to_if(abuse.abuseable, abuse.abuseable_type.gsub(/([a-z\d])([A-Z])/,'\1 \2'), abuse.abuseable)
  end

  def link_to_edit(url)
    # link_to_remote("edit", :url => url, :method => :get, :html => { :class => "modal" })
    link_to("edit", url, :method => :get, :remote => true, :class => "modal")
  end

  def link_to_question_referral_owner(owner)
    owner_path = owner.is_a?(Group) ? group_path(owner.id) : profile_path(owner.id)
    link_to(truncate(owner.name, :length => 22), owner_path)
  end

############ MARKED FOR DERPRECATION DOES THIS REALLY NEED TO BE IN HERE?  Or is it profile centric...
############ replaced with profile.biz_card_labels(q)     --jes
  def profile_question_label_for(profile_q)
    #Profile.biz_card_labels(profile_q)            looking towards this method after deprecation
    Profile.get_questions_from_config[profile_q.to_s]['label']
  end

  def contact_info_order(profile)
    sponsor_info = Config[:sponsor_member_contact_info_order]
    profile.is_sponsored? && sponsor_info ? sponsor_info : Config[:contact_info_order]
  end

  def analytics_tracker_code
    # @@tracker_code ||= Config[:analytics_tracker_code]
    Config[:analytics_tracker_code]    
  end

  class LocalJavaScriptGenerator
    include ActionView::Helpers::PrototypeHelper::JavaScriptGenerator::GeneratorMethods
    def initialize()
      @lines = ''
    end
  end

  def local_js_gen
    @@local_js_gen ||= LocalJavaScriptGenerator.new
  end

  def theme_colors
    # @@theme_colors ||= Config['themes'][Config[:theme]]
    Config['themes'][Config[:theme]]
  end

  def site_base_url
    # @@site_base_url ||= URI.parse(Config[:site_base_url]).to_s
    URI.parse(Config[:site_base_url]).to_s
  end

  def site_name
    # @@site_name ||= Config[:site_name]
    Config[:site_name]
  end
  
  def sso_logout_url
    # @@sso_logout_url ||= Config[:tfce_sso_logout_url]
    Config[:tfce_sso_logout_url]
  end
  
  def sso_portal_url
    # @@sso_portal_url ||= Config[:tfce_sso_portal_url]
    Config[:tfce_sso_portal_url]
  end
  
  def sso_portal_url_text
    # @@sso_portal_url_text ||= Config[:tfce_sso_portal_url_text]
    Config[:tfce_sso_portal_url_text]
  end

  def bookings_options_for_select(bookings)
    options_for_select([["Select Booking...",""]].concat(bookings.collect { |booking| ["#{smart_date booking.start_time, booking.end_time} #{booking.locations}",booking.id] }))
  end

  @@country_codes = [["Afghanistan","AF"],["Albania","AL"],["Algeria","DZ"],["American Samoa","AS"],["Andorra","AD"],["Angola","AO"],["Anguilla","AI"],["Antigua and Barbuda","AG"],["Argentina","AR"],["Armenia","AM"],["Aruba","AW"],["Australia","AU"],["Austria","AT"],["Azerbaijan","AZ"],["Bahamas","BS"],["Bahrain","BH"],["Bangladesh","BD"],["Barbados","BB"],["Belarus","BY"],["Belgium","BE"],["Belize","BZ"],["Benin","BJ"],["Bermuda","BM"],["Bhutan","BT"],["Bolivia","BO"],["Bosnia and Herzegovina","BA"],["Botswana","BW"],["Bouvet Island","BV"],["Brazil","BR"],["British Indian Ocean Territory","IO"],["Brunei","BN"],["Bulgaria","BG"],["Burkina Faso","BF"],["Burundi","BI"],["Cambodia","KH"],["Cameroon","CM"],["Canada","CA"],["Cape Verde","CV"],["Cayman Islands","KY"],["Central African Republic","CF"],["Chad","TD"],["Chile","CL"],["China","CN"],["Christmas Island","CX"],["Cocos (Keeling) Islands","CC"],["Colombia","CO"],["Comoros","KM"],["Congo","CG"],["Congo - Democratic Republic of","CD"],["Cook Islands","CK"],["Costa Rica","CR"],["Cote d'Ivoire","CI"],["Croatia","HR"],["Cuba","CU"],["Cyprus","CY"],["Czech Republic","CZ"],["Denmark","DK"],["Djibouti","DJ"],["Dominica","DM"],["Dominican Republic","DO"],["East Timor","TP"],["Ecuador","EC"],["Egypt","EG"],["El Salvador","SV"],["Equitorial Guinea","GQ"],["Eritrea","ER"],["Estonia","EE"],["Ethiopia","ET"],["Falkland Islands (Islas Malvinas)","FK"],["Faroe Islands","FO"],["Fiji","FJ"],["Finland","FI"],["France","FR"],["French Guyana","GF"],["French Polynesia","PF"],["French Southern and Antarctic Lands","TF"],["Gabon","GA"],["Gambia","GM"],["Gaza Strip","GZ"],["Georgia","GE"],["Germany","DE"],["Ghana","GH"],["Gibraltar","GI"],["Greece","GR"],["Greenland","GL"],["Grenada","GD"],["Guadeloupe","GP"],["Guam","GU"],["Guatemala","GT"],["Guinea","GN"],["Guinea-Bissau","GW"],["Guyana","GY"],["Haiti","HT"],["Heard Island and McDonald Islands","HM"],["Holy See (Vatican City)","VA"],["Honduras","HN"],["Hong Kong","HK"],["Hungary","HU"],["Iceland","IS"],["India","IN"],["Indonesia","ID"],["Iran","IR"],["Iraq","IQ"],["Ireland","IE"],["Israel","IL"],["Italy","IT"],["Jamaica","JM"],["Japan","JP"],["Jordan","JO"],["Kazakhstan","KZ"],["Kenya","KE"],["Kiribati","KI"],["Kuwait","KW"],["Kyrgyzstan","KG"],["Laos","LA"],["Latvia","LV"],["Lebanon","LB"],["Lesotho","LS"],["Liberia","LR"],["Libya","LY"],["Liechtenstein","LI"],["Lithuania","LT"],["Luxembourg","LU"],["Macau","MO"],["Macedonia - The Former Yugoslav Republic of","MK"],["Madagascar","MG"],["Malawi","MW"],["Malaysia","MY"],["Maldives","MV"],["Mali","ML"],["Malta","MT"],["Marshall Islands","MH"],["Martinique","MQ"],["Mauritania","MR"],["Mauritius","MU"],["Mayotte","YT"],["Mexico","MX"],["Micronesia - Federated States of","FM"],["Moldova","MD"],["Monaco","MC"],["Mongolia","MN"],["Montenegro","ME"],["Montserrat","MS"],["Morocco","MA"],["Mozambique","MZ"],["Myanmar","MM"],["Namibia","NA"],["Naura","NR"],["Nepal","NP"],["Netherlands","NL"],["Netherlands Antilles","AN"],["New Caledonia","NC"],["New Zealand","NZ"],["Nicaragua","NI"],["Niger","NE"],["Nigeria","NG"],["Niue","NU"],["Norfolk Island","NF"],["North Korea","KP"],["Northern Mariana Islands","MP"],["Norway","NO"],["Oman","OM"],["Pakistan","PK"],["Palau","PW"],["Panama","PA"],["Papua New Guinea","PG"],["Paraguay","PY"],["Peru","PE"],["Philippines","PH"],["Pitcairn Islands","PN"],["Poland","PL"],["Portugal","PT"],["Puerto Rico","PR"],["Qatar","QA"],["Reunion","RE"],["Romania","RO"],["Russia","RU"],["Rwanda","RW"],["Saint Kitts and Nevis","KN"],["Saint Lucia","LC"],["Saint Vincent and the Grenadines","VC"],["Samoa","WS"],["San Marino","SM"],["Sao Tome and Principe","ST"],["Saudi Arabia","SA"],["Senegal","SN"],["Serbia","RS"],["Seychelles","SC"],["Sierra Leone","SL"],["Singapore","SG"],["Slovakia","SK"],["Slovenia","SI"],["Solomon Islands","SB"],["Somalia","SO"],["South Africa","ZA"],["South Georgia and the South Sandwich Islands","GS"],["South Korea","KR"],["Spain","ES"],["Sri Lanka","LK"],["St. Helena","SH"],["St. Pierre and Miquelon","PM"],["Sudan","SD"],["Suriname","SR"],["Svalbard","SJ"],["Swaziland","SZ"],["Sweden","SE"],["Switzerland","CH"],["Syria","SY"],["Taiwan","TW"],["Tajikistan","TJ"],["Tanzania","TZ"],["Thailand","TH"],["Togo","TG"],["Tokelau","TK"],["Tonga","TO"],["Trinidad and Tobago","TT"],["Tunisia","TN"],["Turkey","TR"],["Turkmenistan","TM"],["Turks and Caicos Islands","TC"],["Tuvalu","TV"],["Uganda","UG"],["Ukraine","UA"],["United Arab Emirates","AE"],["United Kingdom","GB"],["United States","US"],["Uruguay","UY"],["Uzbekistan","UZ"],["Vanuatu","VU"],["Venezuela","VE"],["Vietnam","VN"],["Virgin Islands - British","VG"],["Virgin Islands - United States","VI"],["Wallis and Futuna","WF"],["West Bank","PS"],["Western Sahara","EH"],["Yemen","YE"],["Zambia","ZM"],["Zimbabwe","ZW"]]

  def country_codes
    @@truncated_country_codes ||= @@country_codes.each{ |cc| cc[0] = truncate(cc[0], :length => 20) }
  end

  def country_options
    @@country_options ||= options_for_select(@@country_codes)
  end

end
