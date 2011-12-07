class GroupTextIndex < ActiveRecord::Base

  belongs_to :group

  xss_terminate :except => self.column_names

end
