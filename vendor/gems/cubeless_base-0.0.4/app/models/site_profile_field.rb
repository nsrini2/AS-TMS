class SiteProfileField < ActiveRecord::Base
  include Config::Callbacks

  has_one :site_profile_page, :dependent => :destroy
  has_one :site_biz_card, :dependent => :destroy

  def profile_page_position
    site_profile_page ? site_profile_page.position.to_i : 0
  end
  def biz_card_position
    site_biz_card ? site_biz_card.position.to_i : 0
  end
  
  # Fields that have to be there
  def sticky?
    question.to_s == "profile_1" || question.to_s == "profile_2"
  end

  class << self
    
    def max_fields
      12
    end
    def fields_available
      # The +1 accounts for the email field
      max_fields + 1 - count
    end
    def fields_available?
      fields_available > 0
    end
    
    def question_names
      (1..12).to_a.collect { |i| "profile_#{i}"}
    end
    def question_names_available
      all_qn = question_names
      all.collect{ |f| all_qn.delete(f.question) }
      all_qn
    end
    
  end

end
