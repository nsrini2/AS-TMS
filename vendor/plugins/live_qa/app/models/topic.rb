class Topic < ActiveRecord::Base
  attr_accessor :votes_up, :votes_down
  
  belongs_to :chat
  belongs_to :profile, :foreign_key => :owner_id
  has_many :posts, :dependent => :destroy, :order => "posts.id ASC"
  has_one :chat_topic_index, :dependent => :destroy
  validates_inclusion_of :status, :in => ["open", "active", "closed" ]
  validates_presence_of :chat_id, :owner_id, :title
  
  # NAMED SCOPES
  # named_scope :named, lambda { |name| {:conditions => ['patch_name = ?', name] }  }  
  
  named_scope :closed, :conditions => 'status = "closed" ', :order => 'start_at ASC'
  named_scope :open, :conditions => 'status = "open" ', :order => 'updated_at DESC'
  named_scope :active, :conditions => 'status = "active" ', :order => 'start_at DESC'
  
  
  before_validation :default_values
  
  def after_save
    #if the chat is inactive, Topic won't find it
    if self.chat  
      # process the indexing in dalay job
      ChatTopicIndex.update_indices(self) unless self.chat.on_air?
    else
      chat_topic_index.destroy  
    end
  end
  
  def display_name
    profile.first_name + " " + profile.last_name.first + "."
  end
  
  def default_values
    self.status = 'open' unless self.status
  end

  def discussed?
    self.status != "open"
  end
  
  def ranking
    # figure out voting thing
    self.id
  end

  def mine?(profile)
    self.owner_id == profile.id
  end
  
  def newest_post_id
    self.posts.empty? ? 0 : self.posts.last.id
  end

class << self
  def find_by_index(query, chat_tpoic_filters)
    ChatTopicIndex.find_by_keywords(query, chat_tpoic_filters)
  end
  
  def mr_external_type
    "Chat::Topic"
  end

end  
    
end
