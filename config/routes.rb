AgentStream::Application.routes.draw do

  devise_for :supplier_users

  match '/join' => 'profiles#hub'
  match '/search' => 'search#index', :as => :search
  match '/notes/new' => 'notes#new', :as => :new_note
  match '/messages/autocomplete' => 'notes#autocomplete_for_message', :as => :autocomplete_for_message_note
  match '/refer_a_friend' => 'public_content#refer_a_friend'
  match '/refer-a-friend' => 'public_content#refer_a_friend'
  match '/referafriend' => 'public_content#refer_a_friend'
  match '/channels' => 'display#channels'
  

  # NEWS
  match '/news' => 'news#index', :as => :news, :via => :get
  match '/news/post/:id' => 'news#post', :as => :news_post, :via => :get
  match '/news/post/:id/edit' => 'news#edit_post', :as => :edit_news_post, :via => :get
  match '/news/post/:id/update' => 'news#update_post', :via => [:post, :put], :as => :update_news_post
  match '/news/post/:id/delete' => 'news#destroy', :as => :delete_news_post, :via => :delete
  match '/news/follow/' => 'news#follow', :as => :news_follow, :via => :post
  
  #VOTES
  match '/votes/helpful' => 'votes#helpful', :via => :post
  match '/votes/not_helpful' => 'votes#not_helpful', :via => :post
  match 'companies/votes/helpful' => 'votes#helpful', :via => :post
  match 'companies/votes/not_helpful' => 'votes#not_helpful', :via => :post
  
  
  # MM2: I have no idea why this won't work in the de routes file...but it won't... :(
  match '/offers/:id/book', :to => 'offers#book', :as => :book_offer
  match '/offers/:id/reviews', :to => 'reviews#create', :via => :post
  match '/offers/:offer_id/reviews', :to => 'reviews#index', :via => :get
  resources :offers
  
  resources :favorites

  match "/panda/authorize_upload", :to => "panda#authorize_upload"
  
  # MM2: Make DE the default report route
  match "/reports/prepare/*p", :to => "reports#prepare"
  resource :reports do
    get :favorites
    get :prepare
  end
  
  namespace "companies" do
      match '/hub/(:id)' => 'hub#show', :via => :get
      match '/hub/create_question' => 'hub#create_question', :via => :post
      
      resources :questions do  
        match 'update' => 'questions#update', :via => :post
        resources :answers do
        end
      end
      
      match '/blog(/:id)' => 'blog_posts#index'
      resource :blog, :controller => "blog" do
        #SSJ -- I hate this, but not sure why other routes are not working...
        match '/blog_posts/create' => 'blog_posts#create', :via => :post
        resources :blog_posts do
          resources :comments
        end  
      end  
      match '/members/:id' => 'members#index'
  end
  
  # Badges
  match '/profiles/:id/badges', :controller => 'profiles', :action => 'badges', :as => :profile_badges
  
  # SSJ Cubeless
  match '/mqjsproxy' => 'mapquest_proxy#jsproxy', :as => :mqjsproxy
  match '/our_story' => 'display#our_story'
  match '/terms_and_conditions' => 'display#terms_and_conditions'
  match '/ping' => 'display#ping'
  match '/stream' => 'display#event_stream'

  match 'css/screen.css' => 'css#screen'
  match 'css/:stylefile.css' => 'css#css'
  match 'css/:subdir/:stylefile.css' => 'css#subdir'

  # if SsoController.configured?
    resources :sso do
      collection do
        get :call
        get :srw
        get :accept_terms_and_conditions
        post :link_account
      end
    end
  # end

  # resource :backdoor #if BackdoorController.enabled?

  resources :about_us do
    collection do
      post :create
    end
  end

  resources :abuse, :controller => "abuses"
  resource :account, :controller => "account" do
    member do
      match :change_email
      post :accept_terms_and_conditions
      match :login
      get :registration_confirmation
      get :logout
      match :email_subscriptions
      match :change_password
      get :edit
      match :signup
      post :quick_register
      get :quick_registration_confirmation
    end
  end

  resources :widgets do
    collection do
      get :default_widget
    end
  end

  match '/widgets/:id' => 'widgets#show'
  match '/stream_events' => 'activity_stream_events#index', :as => :stream_events
  resource :admin, :controller => "admin" do
    collection do
      match :clear_lock
      post :create_user
      get :stats_summary
      get :environment
      post :update_user
      get :no_photos
      get :metasearch
      get :about_us
      get :activity_stream_messages
      get :marketing_messages
      get :showcase_marketing_messages
      get :rss_feeds
      match :stats_by_date
      match :welcome_note
      match :showcase_text
      get :user_setup
      get :current_awards
      get :profiles_summary
      match :welcome_email
      get :shady_admin
      get :manage_users
      get :awards_archive
      get :lists_summary
      get :reset_welcome_email
      match :shady_history
      get :auto_complete_for_welcome_note
      get :system_announcement
      get :top_10
      match :upload_users
      get :home_admin
      get :add_user
      get :terms_and_conditions
      get :pending_users
      get :companies
      get :show_company
      get :new_company
      match :create_company
      match :update_company
    end
    member do
      post :modify_user
    end
  end

  namespace :site_admin do
    resources :site_question_categories do
      collection do
        post :reorder
        get :edit_order
      end
    end
    resources :site_profile_fields do
      collection do
        post :update_biz_card
        get :edit_profile_page
        post :update_profile_page
        get :edit_biz_card
      end
    end
    resources :site_profile_question_sections do
      collection do
        post :reorder
        get :edit_order
      end
      member do
        get :edit_questions_order
        post :reorder_questions
      end
    end
    resources :site_profile_questions
    resources :site_registration_fields do
      collection do
        post :reorder
        get :edit_order
      end
    end
  end

  match 'custom_reports/:action' => 'custom_reports#(?i-mx:usage|data_dump|weekly_report)'
  resources :custom_reports do
    collection do
      post :create_preview
      get :form_details
    end
  end

  # match '/reports' => 'reports#index'
  resources :site_admin do
    collection do
      get :question_categories
      get :general
      get :edit_favicon
      post :publish_general
      put :update_favicon
      get :publish
      get :profile_basic
      get :edit_logo
      get :profile_advanced
      put :update_logo
    end
  end

  resource :mass_mail, :controller => :mass_mail  do
    # get :success
    collection do
      get :success
    end
  end

  resources :users do
    collection do
      get :never_logged_in
      post :resend_welcome_bulk
    end
    member do
      post :resend_welcome
      post :clear_lock
      get :registration_details
      post :activate
      post :activate_on_login
    end
  end

  resources :sponsor_accounts do
   member do
	get :delete
        get :category_level
   end
  end


  resources :sponsor_accounts do
    resources :sponsor_members do    
      member do
        post :add_group
        post :remove_group
      end
    end

    resources :sponsor_groups do
      member do
        post :transfer_ownership
        post :add_sponsor
        post :remove_sponsor
        get :delete
       end
    end
  end

  resources :sponsor_members do
    member do
      match :reset_password
      match :unlock
    end
  end

  resources :showcase
 

  resources :api, :controller => "apis" do
    collection do
      get :search_index
      get :user_tokens
      get :photos
      get :groups
      get :profiles
      get :request_key
      get :whoami
      get :widgets
      get :public_key
      post :sync_users
      get :notes
      get :answers
      get :questions
      get :sync_users_status
      get :stream
      get :blog_posts
    end
  end

  resource :api_key

  resources :audit do
    collection do
      match :query
    end
  end

  resources :blog_posts do 
    resources :comments    
    resources :abuse, :controller => "abuses" do
      collection do
        get :abuse_popup
      end
    end
    
    resources :comments
  end

  resources :videos do
    collection do
      get :encoding_info
    end
    member do
      get :admin
      get :remote
      get :remote_image
    end
  end

  resources :bookmarks do
    collection do
      match :create
    end
    member do
      match :remove
    end
  end

  resources :comments do
    resources :abuse, :controller => "abuses" do
      collection do
        get :abuse_popup
      end
    end
  end

  resources :explorations do
    collection do
      get :people_terms_explore
      get :smarts_query
      get :videos
      get :smarts
      get :groups
      get :people_query
      get :people
      get :question_referrers
      get :blogs
      get :profiles_referred_to_question
      get :travels
      get :questions
      get :groups_referred_to_question
      get :statuses
    end
  end

  resources :travels do  
    member do
      get :itinerary
      match :toggle_privacy
    end
  end

  resources :statuses

  resource :feedback, :controller => "feedback" 
  
  resources :global do
    member do
      put :update_inline
    end
  end

  resources :groups do
    member do
      post :resend_all
      get :get_booth_marketing_messages
      get :get_group_links
      get :get_booth_de
      put :update
      post :remove_member
      get :stats_summary
      match :mass_mail
      get :stream
      get :notes
      get :filter_mods
      get :owner_candidates
      match :moderator_settings
      post :assign_moderator
      post :assign_owner
      get :moderators
      get :ownership
      get :news
      get :help_answer
      post :quit
      post :join
      get :members
      get :select_member
      get :edit 
  end

   resources :abuse, :controller => "abuses" do
      collection do
        get :abuse_popup
      end
    end

    resources :group_links
    
    resources :photos
    resource :blog do
      resources :blog_posts do
        resources :comments
      end
      resources :posts do
        resources :comments
      end
    end

    resources :group_posts do
      resources :comments
    end

    resource :announcement, :controller => "group_announcements"

    resources :gallery_photos do
      member do
        match :update, :as => :update, :via => :put
        post :new_comment
        match :rate
        get :delete
      end
    end

    resources :booth_marketing_messages do
    member do
      match :toggle_activation
    end
   end
  end

  resources :marketing_messages do
    member do
      match :toggle_activation
    end
  end

 resources :showcase_marketing_messages do
    member do
      match :toggle_activation
    end
  end

 
 
  
  resources :rss_feeds do
    member do
      match :toggle_activation
    end
  end  
  
  resources :activity_stream_messages do
    member do
      match :toggle_activation
    end
  end

  resources :notes do
    resources :abuse, :controller => "abuses" do
      collection do
        get :abuse_popup
      end
    end
  end

  resources :group_posts do
    member do 
      post :create_reply
    end
    
    resources :abuse, :controller => "abuses" do
      collection do
        get :abuse_popup
      end
    end
  end

  resources :gallery_photos do
    member do
      match :update, :as => :update, :via => :put
    end


    resources :abuse, :controller => "abuses" do
      collection do
        get :abuse_popup
      end
    end
  end

  match '/profiles/karma_popup' => 'profiles#karma_popup' # MM2: Should not have to do this...
  match '/profile/:username' => 'profiles#show'
  match '/profile' => 'profiles#my'
  match '/profiles/:id' => 'profiles#show', :as => :profile, :via => :get # SSJ: Should not have to do this....
  match '/profiles/:id' => 'profiles#update', :as => :update_profile, :via => :put # MM2: Should not have to do this....
  resources :profiles do
    collection do
      get :hub
      get :external
      match :my_widget
      post :toggle_widget
      post :update_widget_sequence
      get :refresh_hot_topics_widget
      get :refresh_explore_profiles_widget
      get :karma_popup
      get :completion_popup
      get :external_widget
    end

    member do
      match :update # TODO: Should be put
      get :awards_popup
      get :groups
      get :watched_questions
      get :watch_list
      get :completion_popup
      get :notes
      get :questions_with_best_answers
      get :questions_answered
      get :questions_asked
      get :matched_questions
      get :more_matched_questions
      get :questions_answers
    end

    resources :abuse, :controller => "abuses" do
      collection do
        get :abuse_popup
      end
    end

    resources :photos do
      member do
        match :select
        put :make_primary
      end
    end

    resource :blog do
      resources :blog_posts do
        resources :comments
      end  
      resources :posts
    end

    resources :watches do
      collection do
        get :groups
        get :profiles
        get :feed
        match :create
      end
    end

    resources :travels do
      member do
        get :itinerary
      end
    end
    
    resources :statuses
  end

  resources :replies do
    resources :abuse, :controller => "abuses" do
      collection do
        get :abuse_popup
      end
    end
  end

  resources :retrievals do
    collection do
      post :admin_reset
    end
    member do
      match :password_reset
    end
  end

  resources :questions do
    member do
      get :similar_questions
      post :update_close
      match :remove
      post :update, :as => "update"
      match :close, :via => :put
    end  
    resources :abuse, :controller => "abuses" do
      collection do
        get :abuse_popup
      end
    end
    
    resources :answers do
      get :vote_best_answer
    end
  end

  resources :answers do
    resources :abuse, :controller => "abuses" do
      collection do
        get :abuse_popup
      end
    end
  end

  resources :question_referrals do
    collection do
      get :auto_complete_for_referral
      get :new
    end
  end

  resources :group_invitations do
    collection do
      get :auto_complete_for_group_invitation_profile
      get :invitation_popup
      post :validate_invitation_profiles
    end
    member do
      match :invitation_request, :via => [:get, :post]
      match :decline_invitation_request, :via => [:get, :post]
      match :accept_invitation_request, :via => [:get, :post]
      match :resend, :via => [:get, :post]
      match :rescind, :via => [:get, :post]
    end
  end

  resources :system_announcements do
    collection do
      post :create
    end
  end

  resources :terms_and_conditions do
    collection do
      post :create
    end
  end

  resources :default_widgets do
    collection do
      post :create
    end
  end


  resources :awards do
    member do
      get :recipients
      post :toggle_visibility
      post :copy
      post :update_image
      get :assign_award
    end
  end

  resources :profile_awards do
    collection do
      get :auto_complete_for_profile_awards
    end
    member do
      delete :destroy
      post :make_default
      post :toggle_visibility
    end
  end

  match '/' => 'profiles#hub', :as => :home
  # --- END Cubeless Routes ---
  
  # match '/:controller(/:action(/:id))'
end
