class Chat < ActiveRecord::Base
  include ActionView::Helpers::DateHelper
  
  belongs_to :profile, :foreign_key => :host_id
  has_many :topics
  has_many :participants, :order => 'presenter DESC' 
  has_many :presenters, :class_name => "Participant", :conditions => "presenter=1"
  
  has_one :chat_photo, :as => :owner, :dependent => :destroy
  
  default_scope :conditions => ['active > 0']
  
  validates_presence_of :start_at, :duration, :title, :host_id
  validates_numericality_of :duration, :host_id
  
  # before_destroy :deactivate
  
  def validate
    unless Chat.allowed_to_create?(self.host)
      errors.add_to_base "#{self.host.screen_name} does not have permission to create a Live Chat Event."
    end 
  end
  
  # call back to insure all topics are closed then this is closed -- not sure how to identify closed
  #   perhaps put a callback on opening a topic that closed all other open topics too
  def after_save
    # SSJ force the topics to save to ensure that the posts get added to the chat_topic_indices table
    # unless active? then the index will be destroyed
    unless self.on_air?
      topics.each {|t| t.save!}
    end
  end
  
  def primary_photo_path(which=:thumb)
    if !chat_photo.nil?
      chat_photo.public_filename(which)
    elsif presenter.respond_to? :primary_photo_path
      presenter.primary_photo_path(which)
    else
      "/images/gen_avatar_large.png"
    end
    rescue Exception => e
      Rails.logger.warn e.message
      "/images/gen_avatar_large.png"     
  end
  
  def start_message
    if on_air? && !in_progress?
      if self.start_at >= Time.now()
        "This Live Chat will start in #{distance_of_time_in_words_to_now(self.start_at)}." 
      else
        "This Live Chat will start soon." 
      end           
    end  
  end
  
  def active?
    self.active > 0
  end  
  
  def on_air?
    self.started_at != nil && self.ended_at == nil
  end
  
  def in_progress?
   if on_air?
     # dropping into SQL to optimise query that will get called alot in live chats
     topic_count = Topic.find_by_sql("SELECT count(id) as topic_count FROM topics WHERE chat_id= '#{self.id}' AND status IN ('active', 'closed');").first.topic_count
     topic_count.to_i > 0
    end 
  end
  
  def closed?
    self.ended_at != nil
  end
  
  def host?(profile)
    self.host == profile
  end
  
  def host
    # Profile.find(self.host_id)
    self.profile
  end
  
  def presenter?(profile)
    presenters.collect {|p| p.profile_id }.include? profile.id
  end
  
  def presenter
    if presenters.first
      presenters.first.profile || host
    else
      host
    end    
  end
  
  def end_at
    self.start_at + (self.duration * 60) if self.duration
  end
  
  def close(profile)
    if host?(profile)
      self.ended_at = Time.now()
      self.save!
      self.deactivate_all_active_topics
    else
      false
    end    
  end
  
  def destroy
    self.active = 0
    if self.save
      return true
    else
      self.errors << "Unable to delete chat!"
      return false 
    end 
    
  end
  
  def attending?
    false
  end
  
  def is_participant?(profile)
    participants.find(:last, :conditions => ["profile_id = ? AND status != ?", profile.id, "canceled"] )
  end
  
  def attendees
    profiles = []
    participants.attendee.each do |p|
      profiles << p.profile # unless self.host?(p.profile) # For now, include the host in attendees
    end  
    profiles.flatten.uniq
  end
  
  def rsvps
    profiles = []
    participants.rsvp.each do |p|
      profiles << p.profile unless self.host?(p.profile)
    end  
    profiles.flatten.uniq
  end

  def activate_topic(topic)
    deactivate_all_active_topics
    topic.update_attributes({ :status => "active", :start_at => Time.now })
  end  
  
  def deactivate_all_active_topics
    self.topics.active.each{ |t| t.update_attributes({ :status => "closed", :end_at => Time.now }) }
  end
  
  def change_notification_trigger?(org_chat)
    self.start_at != org_chat.start_at
  end
  
  def send_chat_update_emails
    Chat.send_chat_update_emails(self.id)
  end  

  def newest_topic_id
    self.topics.empty? ? nil : self.topics.last.id
  end

  def newest_post_id
    self.topics.active.last ? self.topics.active.last.newest_post_id : nil
  end
    
  class << self
    def allowed_to_create?(profile)
      # ssj: this is just a hook to override in AgentStream
      true
    end
    
    def compute_start_at_from_input(input_date, time_hash)
      input_date = input_date.to_date
      input_datetime = "#{input_date.to_s} #{time_hash[:hour]}:#{time_hash[:minutes]}".to_time
      input_timezone = ActiveSupport::TimeZone[time_hash[:zone]]

      ActiveSupport::TimeWithZone.new(nil, input_timezone,input_datetime)
    end
    
    def current
      Chat.find(:all, :conditions => ["ended_at IS null AND active > 0"], :order => 'start_at' )
    end
    
    def upcoming
      Chat.find(:all, :conditions => ["started_at IS null AND ended_at IS null AND active > 0"], :order => 'start_at' )
    end
    
    def live
      Chat.find(:all, :conditions => ["started_at IS NOT null AND ended_at IS null AND active > 0"], :order => 'start_at' )
    end

    def past
      Chat.find(:all, :conditions => ["ended_at IS NOT null AND active > 0"], :order => 'start_at DESC')
    end
    
    def inactive
      Chat.with_exclusive_scope { Chat.find(:all, :conditions => ["active < 1"]) }
    end
    
    def send_chat_update_emails(id)
      chat = Chat.find(id)
      recipients = chat.attendees.collect { |profile| profile.user.email }
      # here recipients.inspect
      BatchMailer.mail(chat, recipients) unless recipients.blank?
    end

  end  
end
