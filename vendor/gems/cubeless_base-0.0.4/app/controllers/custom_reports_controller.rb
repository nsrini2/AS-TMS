class CustomReportsController < ApplicationController
  allow_access_for :all => :report_admin 

  before_filter :setup_reports
  before_filter :setup_klasses, :only => [:new, :edit]
  
  layout 'report_stats_sub_menu'
  
  def usage
    data = CustomReport.agent_stream_usage_report
    send_data(data, 
              :type     => 'text/csv', 
              :filename => "registration_and_content.csv")
  end
  
  def data_dump
    data = CustomReport.sarah_report('data_dump.csv')
    send_data(data, 
              :type     => 'text/csv', 
              :filename => "as_data_dump.csv")
  end
  
  
  def weekly_report
    data = StatusReport.weekly_dump
    filename = "AgentStream-weekly-#{Date.today.strftime("%Y-%m-%d")}.csv"
    send_data(data, :type => 'text/csv; charset=utf-8', :filename => filename)
  end
  
  # GET /custom_reports
  # GET /custom_reports.xml
  def index
    @custom_reports = CustomReport.find(:all)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @custom_reports }
    end
  end

  # GET /custom_reports/1
  # GET /custom_reports/1.xml
  def show
    @custom_report = CustomReport.find(params[:id])
    
    setup_report_params
    setup_table

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @custom_report }
      format.csv { render :text => @table.to_csv }
      format.pdf { send_data @table.to_pdf, :type => "application/pdf", :filename => "report.pdf" }
    end
  end
  
  # GET /custom_reports/create_preview
  # GET /custom_reports/create_preview
  def create_preview
    setup_table
      
    respond_to do |format|
      format.html { render :text => @table.to_html }
      format.csv { render :text => @table.to_csv }
      format.pdf { send_data @table.to_pdf, :type => "application/pdf", :filename => "report.pdf" }
    end
  end
  
  def form_details
    setup_table
    render :partial => "form_details", :locals => { :klass => @klass, :klass_name => @klass_name, :table => @table }
  end
  
  def setup_klasses
    # Build up a collection of classes
    @klasses = Reports.constants.reject{ |c| c == "ReadOnly" || c == "Associations" }.sort
  end
  def setup_klass
    @klass_name = params[:klass].to_s    
    @klass = "Reports::#{@klass_name}".constantize unless @klass_name.blank?
  end
  def setup_table
    setup_klass
    
    # Build up "only" from attributes params
    onlys = extract_attributes

    # Build up "include" from associations params  
    includes = extract_associations

    # Setup the reporting options
    report_options = { :only => onlys, :include => includes }
    report_options.merge!({ :limit => 10 }) unless params[:all]

    @table = @klass.report_table(:all, report_options)
    
    # Ok this is kind of poor placement...but we want some better info if there are no columns
    @table.instance_eval do
      alias :original_as :as
      def as(format, options={})
        if self.column_names.empty? && format == :html
          <<-EOS
            <table>
              <tr>
                <td>No Attributes, Associations, or Content to Display</td>
              </tr>
            </table>
          EOS
        else
          original_as(format, options)
        end
      end
    end
  end
  def setup_report_params
    custom_report_params = Rack::Utils.parse_query(@custom_report.form) # ActionController::AbstractRequest.parse_query_parameters(@custom_report.form)
    custom_report_params.delete("authenticity_token")
    # custom_report_params.delete("klass") if @klass
    
    params.merge!(custom_report_params)
  end
  
  def extract_attributes
    onlys = []
    
    if params[:attributes]
      params[:attributes].each_pair do |k,v|
        onlys << k.to_sym
      end
    end
    
    onlys
  end
  def extract_associations
    includes = {}
    
    if params[:associations]
      params[:associations].each_pair do |k,v|
        if v && v.is_a?(Hash) && !v.empty?
          includes[k.to_sym] = { :only => v.keys }
        end
      end
    end
    
    includes    
  end

  # GET /custom_reports/new
  # GET /custom_reports/new.xml
  def new
    @custom_report = CustomReport.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @custom_report }
    end
  end

  # GET /custom_reports/1/edit
  def edit
    @custom_report = CustomReport.find(params[:id])
    
    setup_report_params
    setup_table
  end

  # POST /custom_reports
  # POST /custom_reports.xml
  def create    
    @custom_report = CustomReport.new(params[:custom_report])

    respond_to do |format|
      if @custom_report.save
        flash[:notice] = 'Custom Report was successfully created.'
        format.html { 
          if request.xhr?
            render :text => "Success"
          else
            redirect_to(@custom_report)
          end
        }
        format.xml  { render :xml => @custom_report, :status => :created, :location => @custom_report }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @custom_report.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /custom_reports/1
  # PUT /custom_reports/1.xml
  def update
    @custom_report = CustomReport.find(params[:id])

    respond_to do |format|
      if @custom_report.update_attributes(params[:custom_report])
        flash[:notice] = 'Custom Report was successfully updated.'
        format.html { 
          if request.xhr?
            render :text => "Success"
          else
            redirect_to(@custom_report)
          end
        }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @custom_report.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /custom_reports/1
  # DELETE /custom_reports/1.xml
  def destroy
    @custom_report = CustomReport.find(params[:id])
    @custom_report.destroy

    respond_to do |format|
      format.html { redirect_to(custom_reports_url) }
      format.xml  { head :ok }
    end
  end
  
  private
  # I know that's kind of weird...
  # I don't want the creation of these reports to happen during initialization and slow down the start up of the app
  # If it slows down the Report Admin experience, I can live with that.  
  def setup_reports
    require File.dirname(__FILE__) + '/../models/reports' unless Object.constants.include?("Reports")
  end
end
