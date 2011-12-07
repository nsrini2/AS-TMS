class StatusTextIndex < ActiveRecord::Base

  belongs_to :status

  xss_terminate :except => self.column_names

end
