class BoothVideo < ActiveRecord::Base
 belongs_to :group
 validates_presence_of :panda_video_id
 validates_presence_of :group_id
 validates_uniqueness_of :group_id

  def panda_video
    @panda_video ||= Panda::Video.find(panda_video_id)
  end
end
