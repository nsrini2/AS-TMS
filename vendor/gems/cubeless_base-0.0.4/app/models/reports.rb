require 'ruport'

require 'reports/read_only'
require 'reports/associations'

# Alias the ActiveRecord::Base.find method to ActiveRecord::Base.original_find
# Many of our AR models have overwritten find, which sucks for reporting
ActiveRecord::Base.class_eval do
  class << self
    alias_method :original_find, :find
  end
end

module Reports
  # Method creates classes in the Reports namespace
  def self.create_class(class_name, superclass, &block)
    # puts "Creating Class for #{class_name}"
    Rails.logger.info "Creating Class for #{class_name}"
    
    klass = Class.new superclass, &block
    Reports.const_set class_name, klass
    Object.const_set "Reports", Reports
  end

  def self.create_reports_class(class_name)
    create_class(class_name, class_name.constantize) do
      include Reports::ReadOnly
      extend Reports::Associations

      acts_as_reportable
      has_reportable_associations
      
      # Get find back to the OG
      class << self
        alias_method :find, :original_find
      end
    end
    
    # puts "Reporting class created for: #{class_name}"
  end
  
  def self.build_reports_class_from_class_name(class_name)
    # puts "BUILD REPORTS CLASS"
    begin
      klass = class_name.constantize
      # puts "KLASS: #{klass}"
      if klass.is_a?(Class) && (klass.superclass == ActiveRecord::Base || klass.ancestors.include?(ActiveRecord::Base))
        # puts "IF MET"
        # Try to find a matching reports class
        # If none exists, it will raise a NameError exception and then build the class
        begin          
          reports_klass = "Reports::#{class_name}".constantize
          # Ensure the associations are loaded
          reports_klass.has_reportable_associations
        rescue NameError
          # puts "NAME ERROR: #{$!}"
          
          create_reports_class(class_name)
        end
      end
    rescue
      puts "RESCUE ME"
      message = "Problem building a reports class for #{class_name}: #{$!}"
      puts message
      Rails.logger.warn message
    end
  end
end

# Require our custom report classes
Dir.glob("#{RAILS_ROOT}/app/models/reports/*.rb").each do |path|
  unless path.match("associations") || path.match("read_only")
    require path
  end
end

# puts "======================================"


# Handle engines
Rails::Application.railties.engines.each do |e|

  # Create report classes for all the others
  Dir.glob("#{e.root}/app/models/*.rb").each do |path|
    class_name = path.split("/").last.to_s.split(".").first.to_s.camelcase
    puts class_name

    Reports.build_reports_class_from_class_name(class_name)
  end
end





# DOES NOT APPEAR TO BE NEEDED 
# # Now that we've hit every file, we have to check the 
# # NOTE: This is really not a great way to do this...
Object.constants.each do |name|
  Reports.build_reports_class_from_class_name(name)
end
# Object.constants.each do |name|
#   Reports.build_reports_class_from_class_name(name)
# end