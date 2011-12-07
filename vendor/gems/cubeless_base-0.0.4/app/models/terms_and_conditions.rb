class TermsAndConditions < ActiveRecord::Base
  xss_terminate :sanitize => [:content]
  
  def self.get
    TermsAndConditions.find(:first) || TermsAndConditions.default
  end
  
  class << self
    def default
      tac = TermsAndConditions.new
      tac.content= "Please enter Terms and Conditions content for this site"
      tac
    end
  end
  
end