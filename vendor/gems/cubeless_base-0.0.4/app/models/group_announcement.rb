class GroupAnnouncement < ActiveRecord::Base

  xss_terminate :sanitize => [:content]

  belongs_to :group

  def is_active?
    (start_date.nil? or start_date<Time.now) and (end_date.nil? or end_date>Time.now) and !content.blank?
  end
end