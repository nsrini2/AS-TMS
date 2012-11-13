class Post < ActiveRecord::Base
  belongs_to :topic
  belongs_to :profile, :foreign_key => :author_id
  
  validates :topic_id, :presence => true
  validates :author_id, :presence => true
  validates :body, :presence => true
  
  # # I don't think the belongs_to stuff works with MOCKS but it could be another issue...
  # def profile
  #   Profile.current
  # end
  
  after_save :touch_chat
  
  def touch_chat
    topic.chat.touch!
  end
  
  def display_name
    profile.first_name + " " + profile.last_name.first + "."
  end

  def html_body
    textilize(body)
  end

  def textilize(text, *options)
    options ||= [:hard_breaks]

    if text.blank?
      ""
    else
      textilized = RedCloth.new(text, options)
      html_text = textilized.to_html
      html_text = html_text.gsub(/href=\"*(javascript.*)\"/,"") # Avoid in href javascript
      html_text
    end
  end
  
  def host?
    self.profile == self.topic.chat.host
  end
  

  class << self
    def json_methods
      [:display_name, :html_body, :host?]
    end
  end
  
end
