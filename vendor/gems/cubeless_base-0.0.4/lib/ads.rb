module Ads

  def exploration_ad_units
    @@exploration_ad_units ||= Config['ad_units']['explorations']
  end
  
  def hub_ad_units
    @@hub_ad_units ||= Config['ad_units']['hub']
  end

end