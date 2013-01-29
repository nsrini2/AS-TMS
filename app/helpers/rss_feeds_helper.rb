module RssFeedsHelper
  def link_to_toggle_rss_feed_activation(feed)
    image = feed.active > 0 ? "icon_active.png" : "icon_inactive.png"
    title = feed.active > 0 ? "Active feed" : "Click to activate"
    link_to(image_tag("/images/#{image}", :title => title, :alt => "", :width => 20, :height => 32), toggle_activation_rss_feed_path(feed), :class => 'toggle_marketing_message')
  end
end
