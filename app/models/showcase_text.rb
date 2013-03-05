require 'singleton'
class ShowcaseText < ActiveRecord::Base
   # include Singleton
validates_presence_of :text

@@text="Welcome to the Travel Market Showcase"

def self.get
   ShowcaseText.first || ShowcaseText.create.reset
end

def self.reset
    ShowcaseText.get.reset
end
  
def reset
    self.update_attributes({ :text => @@text })
    return self
end

end
