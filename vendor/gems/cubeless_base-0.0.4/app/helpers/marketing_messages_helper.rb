module MarketingMessagesHelper

  def custom_message_content(message, &block)
    yield unless message.is_default
  end

  def link_to_remove(message)
    link_to("remove", marketing_message_path(message), :class => "modal delete")
  end

  def default_message_content(message)
    yield if message.is_default
  end

  def link_to_change_image(message)
    link_to("change image", edit_marketing_message_path(message), :class => "modal change_marketing_image")
  end

  def link_to_toggle_activation(message)
    image = message.active ? "icon_active.png" : "icon_inactive.png"
    title = message.active ? "Active message" : "Click to activate"
    link_to(image_tag("/images/#{image}", :title => title, :alt => "", :width => 20, :height => 32), toggle_activation_marketing_message_path(message), :class => 'toggle_marketing_message')
  end

  def link_to_create_marketing_message
    link_to("new marketing message", new_marketing_message_path(), :class => "modal new_marketing_image")
  end

end