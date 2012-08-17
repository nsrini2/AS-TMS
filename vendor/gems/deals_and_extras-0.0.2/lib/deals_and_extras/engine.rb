require 'deals_and_extras'
require "rails"

module DealsAndExtras
  class Engine < Rails::Engine
    puts "Loading Deals and Extras Engine ..."
    # paths.vendor               "vendor", :load_path => true
    # paths.vendor.plugins      "vendor/plugins"
    # puts "D+E Engine"
    # engine_name :deals_and_extras
  end
end