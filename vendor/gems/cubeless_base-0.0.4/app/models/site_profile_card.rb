class SiteProfileCard < ActiveRecord::Base
  include Config::Callbacks

  belongs_to :site_profile_field

end
