require 'trusted_fce'

class SsoController < ApplicationController

  skip_before_filter :require_auth
  
  @@tfce = Config[:tfce_sso_url] ? TrustedFce.new(Config[:tfce_sso_my_domain],Config[:tfce_sso_url],Config[:tfce_sso_secret]) : nil

  def self.configured?
    !@@tfce.nil?
  end
  
  def call

    cmd, options = @@tfce.decrypt_options(params['tfce'])
    
    case cmd
      
      # a Provider could put an <iframe> on the page /w a request_url to this command, to help the user logout of all Consumer sites (like us).
      when 'sso_logout'
        if logged_in?
          user = current_user
          raise 'expired' unless @@tfce.valid?(options,user.tfce_req_nonce)
          user.update_attributes(:tfce_req_nonce => @@tfce.new_nonce)
          expire_session
        end
        return render(:text => 'logged out')
        
      when 'sso_login_response'
        raise 'expired' unless @@tfce.valid?(options)

        sso_id = options['sso/id']
        raise "no sso/id #{options.inspect}" if sso_id.blank?
        user = User.find(:first,:conditions => ['sso_id=?',sso_id])
                
        # if we have all the required fields to create/update user...
        if ['email','first_name','last_name'].inject(true) { |v,attr| v && options.member?(attr) }
          if user.nil?
            user = User.new
            user.sso_id = sso_id
            profile = Profile.new(:user => user)
          end
          profile ||= user.profile
          user.email = options['email']
          profile.first_name = options['first_name']
          profile.last_name = options['last_name']
          profile.screen_name = options['screen_name'] || (profile.first_name + " " + profile.last_name)
          profile.roles = [Role::DirectMember] if profile.roles.blank?
          Profile.transaction do
            user.save! && profile.save!
          end
        end
        
        if user.nil?
          add_to_errors ["We don't have an account for you in our system.","Please contact us for assistance"]
          return redirect_to(new_feedback_path)
        end

        raise 'expired' unless @@tfce.valid?(options,user.tfce_res_nonce)
        
        self.current_user = user
        user.update_attributes(:tfce_res_nonce => @@tfce.new_nonce)
        return_to = session[:return_to]
        return redirect_to(return_to) if return_to
      
      # for testing only  
      # when 'sso_login'
      #         options['sso/id'] = 'sso_test'
      #         options['email'] = 'discard@discard.pri'
      #         options['first_name'] = 'crashtest'
      #         options['last_name'] = 'dummy'
      #         return redirect_to(@@tfce.response_url(options))
      
    end
    
    render :text => "hrmm: #{options.inspect}"
    
  end

  def self.login_url
    @@tfce.request_url('sso_login')
  end
  
end