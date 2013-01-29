require 'singleton'
class DefaultWidget < ActiveRecord::Base
  include Singleton

  xss_terminate :except => [:content] # allow any html in widget code

  def self.get
    DefaultWidget.find(:first) || instance
  end

end