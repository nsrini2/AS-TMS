class GroupLink < ActiveRecord::Base

belongs_to :group
  validates_presence_of :group_id
  validates_presence_of :url
  validates_presence_of :text
end
