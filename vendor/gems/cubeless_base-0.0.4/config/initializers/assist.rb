if File.exists?("#{Rails.root}/lib/assist/profile/registration")
  require "#{Rails.root}/lib/assist/profile/registration"
elsif File.exists?("#{Rails.root}/vendor/plugins/cubeless/lib/assist/profile/registration")
  require "#{Rails.root}/vendor/plugins/cubeless/lib/assist/profile/registration"
end

require "group_owned"
require 'model_util'
require 'user_sync'