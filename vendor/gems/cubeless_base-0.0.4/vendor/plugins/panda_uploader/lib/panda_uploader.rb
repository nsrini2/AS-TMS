# PandaUploader

require 'panda_uploader_helper'

module PandaUploader
  module ClassMethods
  end
  
  def self.included(base)
    base.extend(ClassMethods)
    base.helper PandaUploaderHelper
  end

end