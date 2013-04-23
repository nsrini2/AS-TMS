module MarketingMessagesHelper

  def custom_message_content(message, &block)
    yield unless message.is_default
  end

  def link_to_remove(message)
    if(message.class.to_s=="MarketingMessage")
   	link_to("remove message", marketing_message_path(message), :class => "modal delete")
    elsif(message.class.to_s=="ShowcaseMarketingMessage")
        link_to("remove message", showcase_marketing_message_path(message), :class => "modal delete")
    elsif(message.class.to_s=="BoothMarketingMessage")
        link_to("remove", group_booth_marketing_message_path(message.group,message), :class => "modal delete")
    end
  end

  def default_message_content(message)
    yield if message.is_default
  end

  def link_to_change_image(message)
    if(message.class.to_s=="MarketingMessage")
    	link_to("change image", edit_marketing_message_path(message), :class => "modal change_marketing_image")
    elsif(message.class.to_s=="ShowcaseMarketingMessage")
	link_to("change image", edit_showcase_marketing_message_path(message), :class => "modal change_marketing_image")
    elsif(message.class.to_s=="BoothMarketingMessage")
	link_to("change image", edit_group_booth_marketing_message_path(message.group,message))
    end
  end

  def link_to_toggle_activation(message)
    image = message.active ? "icon_active.png" : "icon_inactive.png"
    title = message.active ? "Active message" : "Click to activate"
    if(message.class.to_s=="MarketingMessage")
      link_to(image_tag("/images/#{image}", :title => title, :alt => "", :width => 20, :height => 32), toggle_activation_marketing_message_path(message), :class => 'toggle_marketing_message')
    elsif(message.class.to_s=="ShowcaseMarketingMessage")
      link_to(image_tag("/images/#{image}", :title => title, :alt => "", :width => 20, :height => 32), toggle_activation_showcase_marketing_message_path(message), :class => 'toggle_marketing_message')
     elsif(message.class.to_s=="BoothMarketingMessage")
      link_to(image_tag("/images/#{image}", :title => title, :alt => "", :width => 20, :height => 32), toggle_activation_group_booth_marketing_message_path(message.group,message), :class => 'toggle_marketing_message')
    end
  end
  
  def link_to_toggle_activity_stream_message_activation(message)
    image = message.active ? "icon_active.png" : "icon_inactive.png"
    title = message.active ? "Active message" : "Click to activate"
    link_to(image_tag("/images/#{image}", :title => title, :alt => "", :width => 20, :height => 32), toggle_activation_activity_stream_message_path(message), :class => 'toggle_marketing_message')
  end

  def link_to_create_marketing_message
    link_to("new marketing message", new_marketing_message_path(), :class => "modal new_marketing_image")
  end

  def link_to_create_showcase_marketing_message
    link_to("new showcase marketing message", new_showcase_marketing_message_path(), :class => "modal new_marketing_image")
  end

  def showcase_marketing_image_tag(message)
    link_to_if(message.link_to_url, image_tag( showcase_marketing_image_path(message), :alt => '', :width => "394", :height => "150"),message.link_to_url,:target => "_blank") if message
  end

  def showcase_marketing_image_path(showcase_marketing_message,which=:large)
    showcase_marketing_message.marketing_image.public_filename(which)
  end

 def link_to_create_booth_marketing_message(group)
    link_to("new booth marketing message", new_group_booth_marketing_message_path(group))
  end

  def booth_marketing_image_tag(message)
    link_to_if(message.link_to_url, image_tag( booth_marketing_image_path(message), :alt => '', :width => "320", :height => "175"),message.link_to_url,:target => "_blank") if message
  end

  def booth_marketing_image_path(booth_marketing_message,which=:large)
    booth_marketing_message.marketing_image.public_filename(which)
  end

end
