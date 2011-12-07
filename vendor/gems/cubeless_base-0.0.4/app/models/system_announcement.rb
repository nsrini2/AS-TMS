require 'singleton'
class SystemAnnouncement < ActiveRecord::Base
  # include Singleton

  xss_terminate :sanitize => [:content]
  
  def before_create
  #  self.created_at_year_month = Date.today.year*100 + Date.today.month
       
  #     c = self.content
  #     self.content =  RedCloth.new(c).to_html 
  end
  # 
  # def before_save 
  #     c = self.content
  #     self.content =  RedCloth.new(c).to_html 
  # end

  def self.update(attributes)
    SystemAnnouncement.get.update_attributes(attributes)
  end

  def self.get
    SystemAnnouncement.first || SystemAnnounement.new # instance
  end

  def self.get_if_active
    result = get
    result.is_active? ? result : nil
  end

  def is_active?
    (start_date.nil? or start_date<Time.now) and (end_date.nil? or end_date>Time.now) and !content.blank?
  end

end