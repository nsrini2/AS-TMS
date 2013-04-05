class BoothVideo < ActiveRecord::Base
   has_one :marketing_video, :as => :owner, :dependent => :destroy
   belongs_to :group
   validates_presence_of :group_id
   validates_presence_of :title

  acts_as_state_machine :initial => :pending
  
  state :pending
  state :converting
  state :converted, :enter => :set_new_filename
  state :error
  
  event :convert do
    transitions :from => :pending, :to => :converting
  end
  
  event :converted do
    transitions :from => :converting, :to => :converted
  end
  
  event :failed do
    transitions :from => :converting, :to => :error
  end

 def convert
  self.convert!
  success = system(convert_command)
  if success && $?.exitstatus == 0
    self.converted!
  else
    self.failure!
  end
 end

protected
  def convert_command
  #construct new file extension
    flv =  "." + id.to_s + ".flv"
  #build the command to execute ffmpeg
    command = <<-end_command
     ffmpeg -i #{ RAILS_ROOT + '/public' + public_filename }  -ar 22050 -ab 32 -s 480x360 -vcodec flv -r 25 -qscale 8 -f flv -y #{ RAILS_ROOT + '/public' + public_filename + flv }
    end_command
   Rails.logger.debug "Converting video...command: " + command
   command
end

# This updates the stored filename with the new flash video file
def set_new_filename
  update_attribute(:filename, "#{filename}.#{id}.flv")
  update_attribute(:content_type, "application/x-flash-video")
end
end
