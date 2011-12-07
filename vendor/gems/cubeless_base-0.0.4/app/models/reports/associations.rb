module Reports
  module Associations
    def has_reportable_associations                
      # Overwrite the original associations with report based associations
      reflections.each_pair do |name,reflection|
        begin
          # Reset the class name of the reflection
          new_class_name = reflection.class_name.to_s.split("::").first == "Reports" ? reflection.class_name : "Reports::#{reflection.class_name}"

          new_class_name.constantize # This should throw a NameError if the report class does not exist

          # Overwrite the association on the reporting class based on information from the reflection
          self.__send__(reflection.macro, reflection.name, reflection.options.merge({ :class_name => new_class_name }))
          
          # puts "#{name} reflection updated"
        rescue NameError
          # Handle the case where there is not a reporting class of that type
          # First let's try to make one
          # begin
          #   Reports.create_reports_class(reflection.class_name)
          #   puts "#{name} reflection updated"
          # rescue
            # puts "#{name} reflection NOT updated. #{$!}"
            Rails.logger.warn "There does not appear be a reporting class for this association: #{$!}"
          #end
        rescue
          # puts "#{name} reflection NOT updated. #{$!}"

          Rails.logger.warn "Error with building Reporting associations #{$!}"
        end    
      end
    end    
  end
end