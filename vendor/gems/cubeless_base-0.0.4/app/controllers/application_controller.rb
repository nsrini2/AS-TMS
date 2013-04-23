require 'ads'
require 'authenticated_system'
require 'cubeless_authentication'
require 'cubeless_authorization'
require 'parent_resource'
require 'utilities'
require 'list_filtering'

class ApplicationController < ActionController::Base
  # MM2: Add exception_notifier and setup
  if Rails.env.production?
    include ExceptionNotification::Notifiable
    ExceptionNotification::Notifier.exception_recipients = %w(mark.mcspadden@sabre.com scott.johnson@sabre.com)
    
    # Necessary to add the view path in this version of Rails. (I think that's the reason.)
    self.append_view_path "#{RAILS_ROOT}/vendor/plugins/exception_notification/lib/../views"

    # Necessary given our override of the rescue_action_in_public method.
    alias_method :rescue_action_in_public_from_exception_notifier, :rescue_action_in_public
  end
  
  # Loading the config from the db
  before_filter :load_config_from_db
  def load_config_from_db
    begin
      Config.load_config_from_db(:reload_assets => true)
    rescue
      Rails.logger.warn "Could not load config from DB: #{$!}"      
    end
  end

  

  # Require SSL in production if it is enabled in site config  
  # Must happen AFTER config is loaded from DB
  # AND must be done this way due to production mode evaulation quirks
  #
  # MM2: I know this is a hack, but it does get the job done.
  before_filter :check_ssl
  def check_ssl
    if Rails.env.production? && Config['ssl_enabled']      
      # Include the SslRequirement module
      self.class.__send__ :include, SslRequirement
      
      # Overwrite the included ssl_required? method
      self.instance_eval do
        def ssl_required?
          true
        end
      end
    end
  end

  layout '_application'

  # prevent against CSRF [security]
  protect_from_forgery

  helper [:profiles, :questions, :groups, :css, :travels, :marketing_messages,:filter_sort,:photos]

  include Ads
  include AuthenticatedSystem
  include CubelessAuthentication
  include CubelessAuthorization
  include ParentResource
  include Utilities
  include ListFiltering
  include ActionView::Helpers::SanitizeHelper
  # include ActionView::Helpers::TextHelper
  helper_method [:add_to_notices, :add_to_errors, :error_messages_beautify, :profile_path, :expire_session]

  before_filter :sso_authenticate  
  before_filter :verify_session
  before_filter :verify_password
  before_filter :require_auth
  before_filter :require_terms_acceptance
  before_filter :audit_admin_request

  def profile_path(profile)
    profile = [profile].flatten.compact.last # TODO: Remove these active relation hacks
    return "/profile" if profile[:id] == current_profile.id
    super(profile)
  end

  def private_group_protection_needed(group=@group)
    return false if current_profile.has_role?(Role::ShadyAdmin) || !group.is_a?(Group) || !group.is_private?
    unless group.is_private_and_members_include?(current_profile) || group.invitations.find_by_receiver_id(current_profile.id)
      return redirect_to(group_path(group))
    end
  end

  def require_terms_acceptance
    return unless Config[:terms_acceptance_required] && logged_in?
    return if current_user.terms_accepted?
    add_to_notices "Please Read the Terms and Conditions and click Accept at the bottom of the page."
    redirect_to(:controller => '/display', :action => 'terms_and_conditions')
  end

  def rescue_action_in_public(exception)
    @error = exception
    
    rescue_action_in_public_from_exception_notifier(exception) if Rails.env.production?
    
    render :template => '/application/error' and return
  end

  # this keeps developer-style exceptions from showing in production from calls from localhost proxies
  alias_method :rescue_action_locally,:rescue_action_in_public

  def error_messages_beautify(errors)
    errors.inject([]){|l, (f, e)| e.to_s.match(/^\^/) ? (l << e[1..-1]) : (f.to_s == "base" ? (l << "#{e}") : (l << "#{f.to_s.underscore.split('_').join(' ').humanize} #{e}"));l}
  end

  def add_to_errors(records_or_msgs=[])
    flash[:errors] ||= []
    Array(records_or_msgs).each do |record_or_msg|
      flash[:errors] += (record_or_msg.is_a?(String) ? [record_or_msg] : error_messages_beautify(record_or_msg.errors))
    end
  end

  def add_to_notices(notices=[])
    flash[:notice] ||= []
    Array(notices).each do |notice|
      flash[:notice] += [notice]
    end
  end

  def show_in_popup(partial, options={})
    oncomplete = options.delete(:oncomplete) if options[:oncomplete]
    render :update do |page|
      page.call 'showPopup', render(:partial => partial, :layout => 'layouts/popup', :locals => options)
      page.call oncomplete if oncomplete
    end
  end

  @@audit_ignore_params = ['authenticity_token','password','password_confirmation','current_password']
  def audit_event(event_name,info={})    
    #!? sub-hashes not captured
    request.parameters.each { |k,v| info[k] = v if !@@audit_ignore_params.member?(k) and v.is_a?(String) and v.length<200 } if (info.delete(:merge_params))
    AuditEvent.create(:who => self.current_profile,
      :name => event_name.to_s,
      :info_hash => info,
      :action => "#{request.parameters['controller']}/#{request.parameters['action']}",
      :target => info.delete(:target),
      :trace_hash => {
        :method => request.method,
        :path => request.path,
        :agent => request.headers['HTTP_USER_AGENT'],
        :referrer => request.headers['HTTP_REFERER']
      })
  end
  
  # audit any changes admins make to the system
  def audit_admin_request
    return if request.get?
    return unless logged_in? and current_profile.has_role?(Role::CubelessAdmin, Role::ReportAdmin, Role::ShadyAdmin, Role::ContentAdmin, Role::UserAdmin, Role::AwardsAdmin, Role::SponsorAdmin)
    audit_event('admin', :merge_params => true)
  end
  
  def is_editable?(object)
    can_edit = object.editable_by?(current_profile)
    return true if can_edit
    audit_event(:unauthorized_edit, {:type => object.class.name, :id => object.id})
    raise Exceptions::UnauthorizedEdit
    return false
  end
  
  def verify_video_enabled
    unless Video.enabled?
      flash[:errors] = "Video is not enabled in this community."
      redirect_to "/" and return
    end
  end

  def verify_travel_enabled
    unless Getthere.Enabled?
      flash[:errors] = "Travel is not enabled in this community."
      redirect_to "/" and return
    end
  end
  
end
