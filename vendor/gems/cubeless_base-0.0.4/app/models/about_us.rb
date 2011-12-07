class AboutUs < ActiveRecord::Base
  xss_terminate :sanitize => [:content]
  
  def self.get
    AboutUs.find(:first) || AboutUs.default
  end
  
  class << self
    def default
      au = AboutUs.new
      au.content= "Please enter about us content for this site"
      au
    end
  end
  
end