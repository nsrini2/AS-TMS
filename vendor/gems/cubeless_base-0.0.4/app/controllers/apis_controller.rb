require 'openssl'
require 'user_sync'

class ApisController < ApplicationController
  include BackgroundProcessing
  
  before_filter :require_api_key
  skip_before_filter :require_api_key, :only => :index
  skip_before_filter :require_auth

  # MM2: For some reason the protect_from_forgery was catching these xml post requests
  skip_before_filter :verify_authenticity_token, :only => [:sync_users]

  # MM2: Lock down to user admins only on sync_users and sync_users_status
  allow_access_for [:sync_users, :sync_users_status] => :user_admin

  def request_doc
    Notifier.deliver_api_doc_for(current_profile)
    Notifier.deliver_api_doc_requested_for(current_profile)
    add_to_notices "API Document Sent"
    redirect_to current_profile
  end

  def index
    render :template => '/notifier/api_key_for'
  end

  def whoami
    return_params = {
      :profile_id => current_profile.id,
      :seconds_since_epoch => Time.now.to_i
    }
    redirect_to = params[:redirect_to]
    return_params[:redirect_to] = redirect_to if redirect_to
    encoded_params = return_params.collect { |k,v| "#{CGI.escape(k.to_s)}=#{CGI.escape(v.to_s)}" }.join('&')
    data = Base64.encode64(api_private_key.private_encrypt(encoded_params))
    if redirect_to
      uri = URI.parse(redirect_to)
      uri.query = "whoami=#{CGI.escape(data)}"
      redirect_to uri.to_s
    else
      render :text => data
    end
  end

  def public_key
    render :text => api_private_key.public_key.to_s
  end

  def questions
    opts = {:summary => true, :limit => 500, :order => "questions.created_at DESC"}
    ModelUtil.add_conditions!(opts, ["questions.profile_id=?", params[:profile_id]]) if params[:profile_id]
    ModelUtil.add_conditions!(opts, ["questions.created_at>?", Date.parse(params[:date])]) if params[:date]
    ModelUtil.add_conditions!(opts, ["questions.open_until>?", Date.parse(params[:open_until])]) if params[:open_until]
    ModelUtil.add_conditions!(opts, ["questions.answers_count>?", params[:num_answers]]) if params[:num_answers]
    @questions = params[:query] ? Question.find_by_keywords(params[:query], opts) : Question.find(:all, opts)
    respond_to do |format|
      format.xml{render :action => 'questions.rxml', :layout => false}
    end
  end

  def profiles
    opts = {:limit => 500}
    opts[:limit] = params[:limit] if params[:limit]
    ModelUtil.add_conditions!(opts, ["profiles.id in ( ? )", params[:id].split(",")]) if params[:id]
    @profiles = params[:name] ? Profile.all_visible_profiles_by_full_name(params[:name], opts) : Profile.find(:all, opts)
    respond_to do |format|
      format.xml{render :action => 'profiles.rxml', :layout => false}
    end
  end

  def groups
    opts = {:limit => 500}
    ModelUtil.add_conditions!(opts, ["groups.created_at>?", Date.parse(params[:date])]) if params[:date]
    ModelUtil.add_conditions!(opts, ["groups.group_memberships_count>?", params[:members]]) if params[:members]
    ModelUtil.add_conditions!(opts, ["groups.activity_status=?", params[:status]]) if params[:status]
    @groups = params[:query] ? Group.find_by_keywords(params[:query], opts) : Group.find(:all, opts)
    respond_to do |format|
      format.xml{render :action => 'groups.rxml', :layout => false}
    end
  end

  def answers
    opts = {:summary => true, :limit => 500, :order => "answers.created_at DESC"}
    ModelUtil.add_conditions!(opts, ["answers.profile_id=?", params[:profile_id]]) if params[:profile_id]
    ModelUtil.add_conditions!(opts, ["answers.question_id=?", params[:question_id]]) if params[:question_id]
    ModelUtil.add_conditions!(opts, ["answers.created_at>?", Date.parse(params[:date])]) if params[:date]
    ModelUtil.add_conditions!(opts, ["answers.best_answer=?", params[:best_answer]]) if params[:best_answer]
    ModelUtil.add_conditions!(opts, ["answers.num_positive_votes>?", params[:positive_votes]]) if params[:positive_votes]
    ModelUtil.add_conditions!(opts, ["answers.num_negative_votes>?", params[:negative_votes]]) if params[:negative_votes]
    @answers = Answer.find(:all, opts)
    respond_to do |format|
      format.xml{render :action => 'answers.rxml', :layout => false}
    end
  end

  def blog_posts
    opts = {:limit => 500, :order => "blog_posts.created_at DESC"}
    ModelUtil.add_conditions!(opts, ["blog_posts.created_at>?", Date.parse(params[:date])]) if params[:date]
    ModelUtil.add_conditions!(opts, ["blog_posts.profile_id=?", params[:profile_id]]) if params[:profile_id]
    ModelUtil.add_conditions!(opts, ["blog_posts.group_id=?", params[:group_id]]) if params[:group_id]
    @items = BlogPost.find(:all, opts)
    respond_to do |format|
      format.xml{render :action => 'blog_posts.rxml', :layout => false}
    end
  end

  def notes
    opts = {:limit => 500, :order => "notes.created_at DESC"}
    opts[:limit] = params[:limit] if params[:limit]
    ModelUtil.add_conditions!(opts, ["notes.created_at>?", Date.parse(params[:date])]) if params[:date]
    ModelUtil.add_conditions!(opts, ["notes.sender_id=?", params[:sender_id]]) if params[:sender_id]
    ModelUtil.add_conditions!(opts, ["notes.receiver_id=?", params[:receiver_id]]) if params[:receiver_id]
    @notes = Note.find(:all, opts.merge!({:include => [:sender, :receiver]}))
    respond_to do |format|
      format.xml{render :action => 'notes.rxml', :layout => false}
    end
  end

  def photos
    opts = {:limit => 500, :order => "attachments.id DESC"}
    ModelUtil.add_conditions!(opts, "parent_id is not null")
    ModelUtil.add_conditions!(opts, ["attachments.width=?", params[:size]]) if params[:size]
    ModelUtil.add_conditions!(opts, ["attachments.id>?", params[:index]]) if params[:index]
    @photos = Attachment.find(:all, opts)
    respond_to do |format|
      format.xml{render :action => 'photos.rxml', :layout => false}
    end
  end

  def stream
    opts = { :limit => 20 }
    opts[:limit] = params[:limit] if params[:limit]
    @stream_events = ActivityStreamEvent.find_summary(:all,opts)
    respond_to do |format|
      format.html { render :partial => 'shared/event_stream', :layout => false }
      format.xml{ render :action => 'stream.rxml', :layout => false }
    end
  end

  def profile_current
    render :text => current_user.id, :layout => false
  end
  
  # POST /sync_users
  # Allows user sync (update/delete) through a posted file (or string)
  # 
  # ==== Params
  #
  # * <tt>:do</tt> - If set to 'reset', forces the UserSyncJob to stop
  # * <tt>:mode</tt> - Currently forced to 'sync'. May be allowed in the future
  # * <tt>:user_data</tt> - The CSV file (or raw csv string) to be used for sync. In 'sync' mode, any user that is in the system that is not in the CSV is marked for deletion.
  # * <tt>:test_run</tt> - If set to anything, the sync is processed but not saved. A log is stilled created of the event. Used for testing
  def sync_users
    respond_to do |format|
      # MM2: Only xml is currently supported
      format.json { render :text => "Not supported." }
      format.html { render :text => "Not supported." }
      format.xml {        
        # MM2: This is mostly based on (and refactored from) AdminController#upload_users
        @job = UserSyncJob.instance
        @job.stop! if params[:do]=='reset'
        if @job.stopped?
          params[:mode] = 'sync'

          # We need to handle both raw strings and ActionController::UploadedStringIO objects
          # ActionController::UploadedStringIO come from uploaded files
          data =  if params[:user_data].respond_to?(:read) #is_a?(ActionController::UploadedStringIO)
                    params[:user_data].read
                  else
                    params[:user_data].to_s
                  end
          
          if params[:mode].blank? || data.blank?
            add_to_errors "Make sure you have set the :user_data param to either a file to upload or a raw csv string."
          else                            
            test_run = params[:test_run].blank?
            
            @job.queue!(:action => params[:mode], :data => data, :commit => test_run)
            
            bg_run_user_sync_job
          end
        end
                
        if flash[:errors]                    
          render_xml_errors 
        else
          render_xml "<status>Success</status>"
        end
      }
    end
  end
  
  # GET /sync_users_status
  # Returns the full xml of the last UserSyncJob that was started
  # This job may be queued, running, or even completed
  def sync_users_status
    respond_to do |format|
      # MM2: Only xml is currently supported
      format.json { render :text => "Not supported." }
      format.html { render :text => "Not supported." }
      format.xml {
        @job = UserSyncJob.instance
        render :xml => @job
      }
    end
  end

  private
  @@api_private_key = nil
  def api_private_key
    return @@api_private_key if @@api_private_key
    return @@api_private_key = OpenSSL::PKey::RSA.new(File.read('config/api_key.pem')) if File.exists?('config/api_key.pem')
    private_key = OpenSSL::PKey::RSA.new(2048)
    File.open('config/api_key.pem',"w+") { |fp| fp << private_key.to_s }
    @@api_private_key = private_key
  end

  # MM2: Ugly way to render xml without using views
  # This solution is the result of having problems with trying to use layouts/text AND set the status
  def render_xml(text, options={})
    render({:text => "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n#{text}"}.merge(options))
  end

  def render_xml_errors
    errors = flash[:errors] || @error
    xml_errors = flash[:errors].to_a.collect{ |e| "  <error>#{e}</error>"}
    
    render_xml "<status>Failure</status>\n<errors>\n#{xml_errors}\n</errors>", :status => 500
  end

end
