require 'singleton'
class WelcomeEmail < ActiveRecord::Base
  # include Singleton
  
  validates_presence_of [:subject, :content]

  xss_terminate :sanitize => [:content]
  
  @@subject = "Welcome to #{Config[:site_name]}!"
  @@content = 
      "<p>Welcome to #{Config[:site_name]}!</p>
      <p>#{Config[:site_name]} is a community that depends on
      member participation for its success. It's a great place to learn
      something new just by asking questions or exploring existing content
      shared from members' experience, expertise or interest. The ability to
      create groups is also available whenever you want to exchange ideas with
      like-minded people or just connect with others.</p>
      <p>So what are you waiting for?  Everyone is curious to meet you!</p>"

  def before_create
    # MM2: A WelcomeEmail does not have this column
    # self.created_at_year_month = Date.today.year*100 + Date.today.month

    # c = self.content
    # self.content =  RedCloth.new(c).to_html 
  end

  def before_save 
    # c = self.content
    # self.content =  RedCloth.new(c).to_html 
  end
  
  def self.get
    WelcomeEmail.first || WelcomeEmail.create.reset
  end
  
  def self.reset
    WelcomeEmail.get.reset
  end
  
  def reset
    self.update_attributes({ :subject => @@subject, :content => @@content })
    return self
  end
  
end