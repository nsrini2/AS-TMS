class BoothVideo < ActiveRecord::Base
   has_one :marketing_video, :as => :owner, :dependent => :destroy
   belongs_to :group
   validates_presence_of :group_id
   validates_presence_of :title

end
