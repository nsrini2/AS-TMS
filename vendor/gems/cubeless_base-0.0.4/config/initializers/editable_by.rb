module Cubeless
  module EditableBy
    def editable_by?(profile)
      self.authored_by?(profile) || profile.has_role?(Role::ShadyAdmin)
    end
    
    def authored_by?(profile)
      profile && (self.profile == profile)
    end
  end
end

ActiveRecord::Base.class_eval do
  include Cubeless::EditableBy
end