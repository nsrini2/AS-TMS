require_cubeless_engine_file :model, :group

class Group < ActiveRecord::Base
  include Notifications::Group
  include Tire::Model::Search
  include Tire::Model::Callbacks
  include Indexed::Group
    
  belongs_to :company
  
  has_many :questions_referred_to_me, :through => :referred_questions, :source => :question,
    :conditions => ['active = 1'], :uniq  => true
    
  has_many :active_questions_referred_to_me, :through => :referred_questions, :source => :question,
    :conditions => ['active = 1 and questions.open_until > ?', Date.today], :uniq  => true
    
  def search_content
    tags
  end
    
end    