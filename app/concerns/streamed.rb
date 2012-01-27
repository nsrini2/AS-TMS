module Streamed
  extend ActiveSupport::Concern
  
  # included do
  #   # scope of self == the Class that included this module
  # end  
  
  module InstanceMethods
    def add_to_activity_stream
      
      if skip_logging?
        Rails.logger.info "object.private? && object.compnay? must be false to be added to activity_stream"
      else
        opts = {}
        # REFACTOR
        case self
          when Group then opts[:group_id] = self.id
          when GroupPhoto then opts[:group_id] = self.owner_id
          when GroupMembership then opts.merge!(:profile_id => self.profile_id, :group_id => self.group_id)
          when ProfileAward then opts[:profile_id] = self.profile.id
          else opts[:profile_id] = self.profile_id
        end
        Rails.logger.info "Adding #{self.class} #{self.id} to ActivityStreamEvent with opts #{opts.inspect}"
        ActivityStreamEvent.add(self.class,self.id,:create,opts) unless opts.empty?
      end    
    end
    
    def remove_from_activity_stream
      Rails.logger.info "Removing #{self.class} #{self.id} from ActivityStreamEvent"
      # REFACTOR
      stream_events = case self.class
                        when Profile
                          ActivityStreamEvent.where("profile_id=#{self.id}") 
                        when Group
                          ActivityStreamEvent.where("group_id=#{self.id}") if self.class==Group
                        else   
                          ActivityStreamEvent.where("klass='#{self.class}' and klass_id=#{self.id}")
                      end 
      stream_events.each do |event|
        event.destroy
      end                 
    end
    
    def add_to_company_stream
      if self.company? && self.profile_id
        Rails.logger.info "Adding #{self.class} #{self.id} to CompanyStreamEvent"
        opts = {:profile_id => self.profile_id }
        CompanyStreamEvent.add(self.class,self.id,:create, self.company_id, opts) unless opts.empty?
      else  
        Rails.logger.warn "Object.company? must be true and Object must have a profile_id to be added to company_stream"
      end  
    end
    
    def remove_from_company_stream
      if self.company?
        Rails.logger.info "Removing #{self.class} #{self.id} from CompanyStreamEvent"
        stream_events = CompanyStreamEvent.where(:klass => self.class).where(:klass_id => self.id)
        stream_events.each do |event|
          event.destroy
        end  
      end
    end
    
    private
    # SSJ 
    # this needs some more refactoring
    def skip_logging?
      # skip logging any company or private events 
      if respond_to?(:company?) && respond_to?(:private?)
        return company? || private?
      end
      
      if respond_to? :company?
        return company?
      end
      
      if respond_to? :private?
        return private?
      end
      
      # REFACTOR classes below to implement :private?
      case self.class
        when BlogPost  
          return self.blog.owner_type=='Group' && self.blog.owner.is_private? 
        when Comment
          return self.owner.is_a?(GroupPost) || (self.owner.is_a?(BlogPost) && self.owner.blog.owner.is_a?(Group) && self.owner.blog.owner.is_private?)
      end
      false
    end
    
  end
  
  module ClassMethods
    def stream_to(*args)
      args.each do |stream|
        unless stream.to_s[/(activity|company)/]
          Rails.logger.warn "No Stream exists for #{stream}."
          next
        end
        self.after_create "add_to_#{stream}_stream".to_sym
        self.after_destroy "remove_from_#{stream}_stream".to_sym
      end  
    end
    
    def stream_on_update
      #
    end  
    
    def stream_on_save
      #
    end
  end    
  
end  

ActiveRecord::Base.send :include, Streamed