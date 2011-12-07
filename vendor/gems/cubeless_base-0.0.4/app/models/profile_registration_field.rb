class ProfileRegistrationField < ActiveRecord::Base
  belongs_to :profile
  belongs_to :site_registration_field
end
