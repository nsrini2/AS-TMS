# class Ruport::Data::Table
#   alias :original_as :as
# end
# module RuportDataTableExtensions
#   def as(*args)
#     if self.column_names.empty? && args.first == :html
#       table = <<-EOS
#         <table>
#           <tr>
#             <td>No Attributes or Associations to Display</td>
#           </tr>
#         </table>
#       EOS
#       
#       table
#     else
#       original_as(args)
#     end
#   end
# end
# Ruport::Data::Table.__send__ :include, RuportDataTableExtensions

class ReportsController < ApplicationController
  
  def index
    puts "============"  #/mam did you live this here ???
    
    y params
    
    puts Reports
    puts Reports.constants.include?("Reports::Question")
    # puts Reports.constants.sort
    
    #require File.dirname(__FILE__) + '/../models/reports'
        
    @klasses = Reports.constants.reject{ |c| c == "ReadOnly" || c == "Associations" }.sort
    
    @table = nil
        
    if !params[:klass].to_s.blank? #request.post?
      puts "Try me"
      @klass_name = params[:klass].to_s    
      @klass = "Reports::#{@klass_name}".constantize    
      
      # Build up "only" from attributes params
      onlys = []
      if params[:attributes]
        params[:attributes].each_pair do |k,v|
          onlys << k.to_sym
        end
      end
    
      includes = {}
      # Build up "include" from associations params
      if params[:associations]
        params[:associations].each_pair do |k,v|
          if v && v.is_a?(Hash) && !v.empty?
            includes[k.to_sym] = { :only => v.keys }
          end
        end
      end
      
      puts "Only: " + onlys.to_s
      puts "Includes: " + includes.to_s

      # if onlys.empty? && includes.empty?
      #   @table = @klass.report_table
      # else
        report_options = { :only => onlys, :include => includes }
        report_options.merge!({ :limit => 10 }) if request.xhr?
        @table = @klass.report_table(:all, report_options)
        
        @table.instance_eval do
          alias :original_as :as
          def as(*args)
            puts "AS ME"
            if self.column_names.empty? && args.first == :html
              puts "Caught me"
              <<-EOS
                <table>
                  <tr>
                    <td>No Attributes or Associations to Display</td>
                  </tr>
                </table>
              EOS
            else
              original_as(args)
            end
          end
        end

      # end
    # else
    #   if params[:klass]
    #     @klass_name = params[:klass].to_s    
    #     @klass = "Reports::#{@klass_name}".constantize    
    # 
    #     # Build up "only" from attributes params
    #     onlys = []
    #     if params[:attributes]
    #       params[:attributes].each_pair do |k,v|
    #         onlys << k.to_sym
    #       end
    #     end
    # 
    #     includes = {}
    #     # Build up "include" from associations params
    #     if params[:associations]
    #       params[:associations].each_pair do |k,v|
    #         if v && v.is_a?(Hash) && !v.empty?
    #           includes[k.to_sym] = { :only => v.keys }
    #         end
    #       end
    #     end
    # 
    #     puts "Only: " + onlys.to_s
    #     puts "Includes: " + includes.to_s
    # 
    #     # if onlys.empty? && includes.empty?
    #     #   @table = @klass.report_table
    #     # else
    #       report_options = { :only => onlys, :include => includes }
    #       report_options.merge!({ :limit => 10 }) if request.xhr?
    #       @table = @klass.report_table(:all, report_options)
    #   end
    end
    
    # puts @table
    
    respond_to do |format|
      format.html {
        if request.xhr?
          render :text => @table.to_html
        else
          render
        end
      }
      format.csv { render :text => @table.to_csv }
      format.pdf { send_data @table.to_pdf, :type => "application/pdf", :filename => "report.pdf" }
    end
  end
  
end