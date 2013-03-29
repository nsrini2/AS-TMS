class GroupLink < ActiveRecord::Base

  belongs_to :group
  validates_presence_of :group_id
  validates_presence_of :url, :message => "We need a url to create a link"
  validates_uniqueness_of :url, :scope => :group_id, :message => "A link with this url already exists"
  validates_presence_of :text, :message => "We need a text to create a link"
  validates_uniqueness_of :text, :scope => :group_id, :message => "A link with this text already exists"
end
