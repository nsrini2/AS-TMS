class WelcomeNote < ActiveRecord::Base
  belongs_to :profile

  validates_length_of :text, :within => 0...100

  validates_presence_of :text, :message => "^Message cannot be blank."
  validates_presence_of :profile_id, :message => "^Sender cannot be blank."

  def before_create
      #  self.created_at_year_month = Date.today.year*100 + Date.today.month

      # c = self.text
      # self.text =  RedCloth.new(c).to_html 
  end

  def before_save 
        # c = self.text
        # self.text =  RedCloth.new(c).to_html 
  end

  def self.update(attributes)
    WelcomeNote.get.update_attributes(attributes)
  end

  def self.get
    WelcomeNote.find(:first) || WelcomeNote.default
  end
  
 class << self  
  def default
    default_note = self.new
    default_note.text = "Welcome to AgentStream! Looking forward to getting to know you better. Ask me questions any time! :)"
    default_note.profile_id = "23871"
    default_note
  end
 end  
  
  
end

