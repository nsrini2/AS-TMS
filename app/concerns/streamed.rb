module Streamed
  extend ActiveSupport::Concern
  
  # included do
  #   # scope of self == the Class that included this module
  # end  
  
  module InstanceMethods
    def add_to_activity_stream
      #
    end
    
    def remove_from_activity_stream
      #
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
  end    
  
end  

ActiveRecord::Base.send :include, Streamed