class SiteRegistrationField < ActiveRecord::Base
  include Config::Callbacks
  
  belongs_to :site_profile_field
  
  validates_presence_of :label
  
  def validate
    if self.label.match(/[^a-zA-Z0-9\s]/)
      errors.add("label", "must contain only letters, numbers, and spaces")
    end
  end
  
  def has_options
    !self.options.to_s.blank?
  end
  alias_method :has_options?, :has_options
  def has_options=(value)
    # Do nothing
  end
end
