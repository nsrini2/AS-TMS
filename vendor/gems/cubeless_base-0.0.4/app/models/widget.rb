# require 'singleton'
class Widget < ActiveRecord::Base
  # include Singleton

  xss_terminate :except => [:content] # allow any html in widget code

  # def self.get
  #   Widget.find(:first) || instance
  # end

end