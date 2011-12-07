require 'responds_to_parent'
ActionController::Base.send :include, RespondsToParent
require 'parent_selector_assertion'
