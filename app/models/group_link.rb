class GroupLink < ActiveRecord::Base
belongs_to :group
 
  validates_presence_of :url
  validates_presence_of :text

 def link
   self.url
 end

 def text
   self.text
 end

end
