# require_de_engine_file 'controller', :admin_controller

require 'user_sync'
class AdminController < ApplicationController
  include BackgroundProcessing

  allow_access_for [:shady_admin, :shady_history] => :shady_admin
  allow_access_for [:stats_summary, :stats_by_date, :profiles_summary, :top_10, :no_photos, :pending_users, :metasearch] => :report_admin
  allow_access_for [:marketing_messages, :welcome_note, :stop_welcome_note, :system_announcement, :welcome_email, :reset_welcome_email, :terms_and_conditions, :about_us] => :content_admin
  allow_access_for [:current_awards, :awards_archive] => :awards_admin
  allow_access_for [:upload_users] => :user_admin
  
  allow_access_for [:environment] => :cubeless_admin 

  # MM2: Removed in the great Rails 3 upgrade of 2011
  # before_filter :report_queries_cache_hack

  class Result
    attr_accessor :data, :table_id, :caption, :columns
    def initialize(data, options={})
      @data, @table_id, @caption, @columns = data, options[:table_id], options[:caption], options[:columns]
    end
  end
  
  def stats_summary
    @reports = [questions_summary_result, referrals_summary_result, karma_summary_result, groups_summary_result, sponsor_groups_summary_result]
    render :layout => 'report_stats_sub_menu', :action => 'stats_table'
  end

  def stats_by_date
    @start_date = string_to_date(params[:start_date]) || beginning_of_month
    @end_date = string_to_date(params[:end_date]) || Date.today
    @reports = [stats_by_date_result(@start_date, @end_date), totals_for_dates_result(@start_date, @end_date)]
    render :layout => 'report_stats_sub_menu'
  end

  def profiles_summary
    @reports = [profile_summary_result, profile_completion_result]
    render :layout => 'report_stats_sub_menu', :action => 'stats_table'
  end

  @@top_10_queries = [["inquirers", ['Screen Name', 'Questions']],
    ["answerers", ['Screen Name', 'Answers']],
    ["referrers", ['Screen Name', 'Referrals']],
    ["most helpful", ['Screen Name', 'Helpfuls']],
    ["most unhelpful", ['Screen Name', 'Unhelpfuls']],
    ["karma", ['Screen Name', 'Points']],
    ["largest groups", ['Name', 'Members']],
    ["most active bloggers", ['Screen Name', 'Posts']],
    ["most active group bloggers", ['Screen Name', 'Posts']],
    ["most active groups", ['Name', 'Points']]]

  def top_10
    @reports = top_10_results_for(@@top_10_queries)
    render :layout => 'report_stats_sub_menu', :action => 'stats_table'
  end
  
  def environment
    @cubeless_params = request.headers  
    @cubeless_lbl = `echo "CUBELESS VER: "`.chomp!    
    @cubeless_ver = `cat #{RAILS_ROOT}/cb_info.data.dtls | grep -i "^URL" | awk -F\/ '{print $NF}'`.chomp! 
    @cubeless_delta_ver = `cat #{RAILS_ROOT}/cb_info.data.dtls  | grep -i "Last Changed Rev" | awk -F: '{print $2}'`.chomp! 
 
    render :layout => 'report_stats_sub_menu'
  end

  def marketing_messages
    @marketing_messages = MarketingMessage.find(:all, :order => 'is_default desc, id asc')
    render :template => 'marketing_messages/marketing_messages', :layout => 'home_admin_sub_menu'
  end
  
  def companies
    @companies = Company.all
    render :template => 'companies/as_admin/index', :layout => 'company_admin_sub_menu'
  end
  
  def show_company
    begin
      @company = Company.find(params[:id]) 
    rescue
      flash[:errors] = "Unable to find selected company!"
    end
    render :template => 'companies/as_admin/show', :layout => 'company_admin_sub_menu'
  end
  
  def new_company
    render :template => 'companies/as_admin/new', :layout => 'company_admin_sub_menu'
  end
  
  def create_company
    @company = Company.new(params[:company])
    if @company.save
      if params[:asset] && params[:asset][:uploaded_data] && !params[:asset][:uploaded_data].blank?
        create_or_update_company_photo(@company)
      end
      flash[:notice] = "Channel #{@company.name} was created!"
      # render :template => 'companies/as_admin/index', :layout => 'company_admin_sub_menu'
      redirect_to :controller => "admin", :action => "companies"
    else
      flash[:errors] = @company.errors
      render :template => 'companies/as_admin/new', :layout => 'company_admin_sub_menu'
    end  
  end
  
  def update_company
    # SSJ -- This is a weird route
    # it reports as admin/:id/update_company -- but it functions as admin/update_company/:id    
    @company = Company.find(params[:id])
    if @company.update_attributes(params[:company])
      flash[:notice] = "#{@company.name} updated!"
      if params[:asset] && params[:asset][:uploaded_data] && !params[:asset][:uploaded_data].blank?
        create_or_update_company_photo(@company)
      end
      redirect_to :controller => "admin", :action => "companies"
    else
      flash[:errors] = "Unable to update #{@company.name}"
      render :template => 'companies/as_admin/show', :layout => 'company_admin_sub_menu'
    end
  end

  def current_awards
    @awards = Award.visible.find(:all, :page => {:size => 5, :current => params[:page]})
    render :template => 'awards/awards', :layout => 'awards_sub_menu'
  end

  def awards_archive
    @awards = Award.hidden.find(:all, :page => {:size => 5, :current => params[:page]})
    render :template => 'awards/awards', :layout => 'awards_sub_menu'
  end

  def welcome_note
    @welcome_note = WelcomeNote.get
    if request.post?
      if params[:commit] == "Delete"
        WelcomeNote.get.destroy
        add_to_notices "Welcome note has been deleted."
      else
        if @welcome_note.update_attributes(:text => params[:welcome_note][:text], :profile_id => params[:welcome_note][:profile_id])
          add_to_notices "Welcome note has been updated."
        else
          add_to_errors @welcome_note
        end
      end
      redirect_to welcome_note_admin_path
    else
      render :layout => 'home_admin_sub_menu'
    end
  end

  def auto_complete_for_welcome_note
    profiles = Profile.find_by_full_name(params[:q], :status => :active, :limit => 20)
    render :partial => 'shared/name_suggestions', :locals => {:suggestions => profiles}
  end

  def welcome_email
    @welcome_email = WelcomeEmail.get
    if request.post?
      if @welcome_email.update_attributes(params[:welcome_email])
        if params[:commit] == "Preview"
          Notifier.deliver_welcome(current_user)
          add_to_notices "A welcome email preview has been sent to #{current_user.email}"
        else
          add_to_notices "Welcome email has been updated."
        end
      else
        add_to_errors @welcome_email
      end
      redirect_to welcome_email_admin_path
    else
      render :layout => 'home_admin_sub_menu'
    end
  end

  def reset_welcome_email
    WelcomeEmail.reset
    add_to_notices "Welcome email has been reset."
    redirect_to welcome_email_admin_path
  end

  def system_announcement
    @object = SystemAnnouncement.get
    render :layout => 'home_admin_sub_menu'
  end

  def about_us
    @object = AboutUs.get
    render :layout => 'home_admin_sub_menu'
  end

  def terms_and_conditions
    @object = TermsAndConditions.get
    render :layout => 'home_admin_sub_menu'
  end

  def shady_admin
    #!H need to deal with poi's in a migration, not the sql
    render :partial => 'admin/shady_template', :locals => {:flagged => Abuse.find(:all, :conditions => ['remover_id is null and abuseable_type <> ?', 'Poi']), :hide => {:search => true}}, :layout => 'shady_admin_sub_menu'
  end

  def shady_history
    @start_date = string_to_date(params[:start_date]) || Date.today - 30
    @end_date = string_to_date(params[:end_date]) || Date.today
    if @end_date - @start_date > 3000
      add_to_errors "Shady history can only be searched in increments of 30 days or less "
      redirect_to request.referer
    else
      @flagged = Abuse.find(:all, :include => [:remover], :conditions => ['remover_id is not null and created_at>=? and created_at<=?',@start_date-1,@end_date+1])
      render :layout => 'shady_admin_sub_menu'
    end
  end

  def no_photos
    headers['Content-Type'] = "application/vnd.ms-excel"
    @users = ReportQueries.users_with_no_photos
    render :layout => false, :action => 'stats_export'
  end

  def pending_users
    headers['Content-Type'] = "application/vnd.ms-excel"
    @users = ReportQueries.pending_users_emails
    render :layout => false, :action => 'stats_export'
  end

  def metasearch
    if params[:query]
    sql = "select 'blog_posts', id, text, created_at from blog_posts where text like ? limit 150 union " +
          "select 'blog_posts', id, title, created_at from blog_posts where title like ? limit 150 union " +
          "select 'questions', id, question, created_at from questions where question like ? limit 150 union " +
          "select 'answers', id, answer, created_at from answers where answer like ? limit 150 union " +
          "select 'notes', id, message, created_at from notes where message like ? limit 150 union " +
          "select 'group_posts', id, post, created_at from group_posts where post like ? limit 150 union " +
          "select 'comments', id, text, created_at from comments where text like ? " +
          "order by created_at desc limit 150"

    @results = []
    term = "%#{params[:query]}%"
    ps = ActiveRecord::Base.connection.raw_connection.prepare(sql)
    ps.execute(term, term, term, term, term, term, term)

    ps.each do |rs|
      hash = {:name => rs[0],
              :item_id => rs[1],
              :text => rs[2].gsub(/<\/?[^>]*>/, "").gsub("#{params[:query]}", '<span class="highlight">' + "#{params[:query]}" + '</span>'),
              :created_at => rs[3]}
      @results << OpenStruct.new(hash)
    end
    ps.close
  end
    
    render :layout => 'report_stats_sub_menu'
  end

  def upload_users
    @job = UserSyncJob.instance
    @job.stop! if params[:do]=='reset'
    if @job.stopped?
      case params[:do]
        when 'clear_status' then @job.clear_results!
        when 'user_upload_log'
          response.headers['Content-Type'] = 'application/octet-stream'
          filename = (@job.options[:action]=='export_csv' || @job.options[:action]=='export_csv_all') ? 'user_export.csv' : 'user_upload_log.txt'
          response.headers['content-disposition'] = "attachment; filename=#{filename}"
          return render(:text => @job.log_output)
        when 'export_csv'
          @job.queue!(:action => 'export_csv')
          bg_run_user_sync_job
          return redirect_to(upload_users_admin_path)
        when 'export_csv_all'
          @job.queue!(:action => 'export_csv_all')
          bg_run_user_sync_job
          return redirect_to(upload_users_admin_path)
      end

      if request.post?
        if params[:mode].blank? || params[:user_data].blank?
          add_to_errors "Make sure you have chosen an action and selected a file to upload."
        else
          @job.queue!(:action => params[:mode], :data => params[:user_data].read, :commit => params[:test_run].blank?)
          bg_run_user_sync_job
          return redirect_to(upload_users_admin_path)
        end
      end
    end
    render :layout => 'user_admin_sub_menu'

  end

  private
  
  def create_or_update_company_photo(company)
    if (company.company_photo = CompanyPhoto.new(params[:asset]))
      company.update_attributes(:primary_photo => company.company_photo)
    end
  end

  # Refactored out to lib/background_processing
  # def bg_run_user_sync_job
  #   system_background(RAILS_ROOT,'rake bam:run_user_sync_job --trace > log/user_sync_job.log 2>&1')
  # end
  # 
  # def system_background(path,cmd)
  #   if ENV.member?('windir')
  #     system("start /D\"#{path}\" /MIN CMD.EXE \"/C #{cmd}\"")
  #   else
  #     system("echo \"cd #{path}; #{cmd}\" | at now")
  #   end
  # end

  @@questions_summary_queries = ["total questions", "open questions", "matched open questions", "unmatched open questions", "open questions with answers",
        "open questions without answers", "number of removes", "questions with answers", "questions without answers", "average number of answers per question",
        "average time until first answer", "percent of questions answered within 1 hour", "percent of questions answered within 24 hours"]

  @@referrals_summary_queries = ["referrals", "referred questions", "open referred questions",
        "average referrals per referred question", "referred questions answered by the people to whom they were referred"]

  @@groups_summary_queries = ["total groups", "public groups", "invite only groups", "private groups"]
  
  @@sponsor_groups_summary_queries = ["total sponsor groups", "public sponsor groups", "invite only sponsor groups", "private sponsor groups"]

  @@profile_summary_queries = ["total active profiles", "total inactive profiles", "profiles pending activation", "total sponsor profiles", "profiles with primary photo", "profiles with complete biz card info", "profiles with complete complex info", "completed profiles with minimum 1 photo"]

  def questions_summary_result
    summary_result("questions summary", @@questions_summary_queries, [['description', false], ['# of questions', true]])
  end

  def referrals_summary_result
    summary_result("referrals summary", @@referrals_summary_queries, [['description', false], ['# of referrals', true]])
  end

  def karma_summary_result
    summary_result("karma summary", "karma counts", [['description', false], ['points needed', true], ['# of profiles', true]])
  end

  def groups_summary_result
    summary_result("groups summary (includes sponsor groups)", @@groups_summary_queries, [['description', false], ['# of groups', true]])
  end

  def sponsor_groups_summary_result
    summary_result("sponsor groups summary", @@sponsor_groups_summary_queries, [['description', false], ['# of sponsor groups', true]])
  end

  def profile_summary_result
    summary_result("profiles summary", @@profile_summary_queries, [['description', false], ['# profiles', true]])
  end

  def profile_completion_result
    summary_result("profile completion", "profile completion", [['description', false], ['percent complete', true]])
  end

  def totals_for_dates_result(start_date, end_date)
    tables = ["users", "answers", "questions"]
    data = [[start_date, end_date]]
    tables.each do |table|
      data[0] << ReportQueries.db_number("select count(1) from #{table} where DATE(created_at) between '#{start_date}' and '#{end_date}'")
    end
    data[0] << [ReportQueries.db_number("select count(1) from blogs b where exists (select 1 from blog_posts bp where b.id = bp.blog_id and DATE(bp.created_at) between '#{start_date}' and '#{end_date}') and b.owner_type = 'Profile'")]
    data[0] << [ReportQueries.db_number("select count(1) from blogs b where exists (select 1 from blog_posts bp where b.id = bp.blog_id and DATE(bp.created_at) between '#{start_date}' and '#{end_date}') and b.owner_type = 'Group'")]
    Result.new(data, :table_id => 'totals_for_dates', :caption => 'Totals for Dates',
      :columns => [{:title => 'Start Date', :class => 'count', :align_data => 'center'},
                    {:title => 'End Date', :class => 'count', :align_data => 'center'},
                    {:title => 'New Accounts', :column_width => '100', :class => 'count', :align_data => 'center'},
                    {:title => 'New Answers', :column_width => '100', :class => 'count', :align_data => 'center'},
                    {:title => 'New Questions', :column_width => '100', :class => 'count', :align_data => 'center'},
                    {:title => 'Active Profile Blogs', :column_width => '100', :class => 'count', :align_data => 'center'},
                    {:title => 'Active Group Blogs', :column_width => '100', :class => 'count', :align_data => 'center'}])
  end

  def stats_by_date_result(start_date, end_date)
    data = []
    range = end_date - start_date
    for day_offset in 0..range
    data << [end_date - day_offset,
             ReportQueries.db_number("select count(1) from users where DATE(created_at) = subdate('#{end_date}',INTERVAL #{day_offset} DAY)"),
             ReportQueries.db_number("select count(1) from answers where DATE(created_at) = subdate('#{end_date}',INTERVAL #{day_offset} DAY)"),
             ReportQueries.db_number("select count(1) from questions where DATE(created_at) = subdate('#{end_date}',INTERVAL #{day_offset} DAY)"),
             ReportQueries.db_number("select count(1) from blogs b where exists (select 1 from blog_posts bp where b.id = bp.blog_id and DATE(bp.created_at) = subdate('#{end_date}',INTERVAL #{day_offset} DAY)) and b.owner_type = 'Profile'"),
             ReportQueries.db_number("select count(1) from blogs b where exists (select 1 from blog_posts bp where b.id = bp.blog_id and DATE(bp.created_at) = subdate('#{end_date}',INTERVAL #{day_offset} DAY)) and b.owner_type = 'Group'")]
    end

    #summary_result("stats by date", data, [['Date', true], ['New Accounts', true], ['New Answers', true], ['New Questions', true]])

    Result.new(data, :table_id => 'stats_by_date', :caption => 'Stats by Date',
      :columns => [{:title => 'Date', :class => 'count', :align_data => 'center'},
                    {:title => 'New Accounts', :column_width => '100', :class => 'count', :align_data => 'center'},
                    {:title => 'New Answers', :column_width => '100', :class => 'count', :align_data => 'center'},
                    {:title => 'New Questions', :column_width => '100', :class => 'count', :align_data => 'center'},
                    {:title => 'Active Profile Blogs', :column_width => '100', :class => 'count', :align_data => 'center'},
                    {:title => 'Active Group Blogs', :column_width => '100', :class => 'count', :align_data => 'center'}])
  end

  def summary_result(table_for, query, columns)
    cols = []
    columns.each do |column|
      title, options = column[0].titleize, column[1]
      x = {:title => title}
      cols << (options ? x.merge!(:class => 'count', :align_data => 'center', :column_width => '100') : x)
    end
    q = (query.is_a?(Array) ? (query.collect{|a| [a.titleize, eval("ReportQueries.#{u(a)}")]}) : eval("ReportQueries.#{u(query)}"))
    Result.new(q, :table_id => u(table_for), :caption => table_for.titleize, :columns => cols)
  end

  def top_10_results_for(queries)
    queries.collect {|report, columns|
      r = eval("ReportQueries.top_x_#{u(report)}")
      (Result.new(r, :table_id => "top_10_#{u(report)}", :caption => "Top 10 #{report.titleize}",
        :columns => [{:title => 'Rank', :column_width => '100', :class => 'count', :align_data => 'center'},
                      {:title => columns[0]},
                      {:title => columns[1], :column_width => '100', :class => 'count', :align_data => 'center'}]))
    }
  end

  def u(str) #works similarly to rails underscore method, except this one modifies spaces
    str.gsub(/\s/,'_').downcase
  end

  #!H hack to fix old optimization that cached the total_profiles in a static... we need caching, but didnt have time
  # to refactor... resetting the cached var on any request.
  # MM2: REMOVED IN THE GREAT RAILS 3 UPGRADE OF 2011 
  # def report_queries_cache_hack
  #     ReportQueries.reset_total_profiles_cache!
  #   end
  
  def action_missing(method_name)    
    if Rails.application.routes.recognize_path("/deals_and_extras/admin/#{method_name}")
      puts "Found a DE route for #{method_name}"
      redirect_to "/deals_and_extras/admin/#{method_name}" and return
    else
      super
    end
  end

end
