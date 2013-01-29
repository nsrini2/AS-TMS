# Rails::Application.routes.draw do
#     
#   match '/mqjsproxy' => 'mapquest_proxy#jsproxy', :as => :mqjsproxy
#   match '/our_story' => 'display#our_story'
#   match '/terms_and_conditions' => 'display#terms_and_conditions'
#   match '/ping' => 'display#ping'
#   match '/stream' => 'display#event_stream'
# 
#   match 'css/screen.css' => 'css#screen'
#   match 'css/:stylefile.css' => 'css#css'
#   match 'css/:subdir/:stylefile.css' => 'css#subdir'
# 
#   # if SsoController.configured?
#     resources :sso do
#       collection do
#         get :call
#       end
#     end
#   # end
# 
#   resource :backdoor #if BackdoorController.enabled?
#   
#   resources :about_us do
#     collection do
#       post :create
#     end
#   end
# 
#   resources :abuses
#   resource :account, :controller => "account" do
#     member do
#       match :change_email
#       post :accept_terms_and_conditions
#       match :login
#       get :registration_confirmation
#       get :logout
#       match :email_subscriptions
#       match :change_password
#       get :edit
#       match :signup
#     end
#   end
# 
#   resources :widgets do
#     collection do
#       get :default_widget
#     end
#   end
# 
#   match '/widgets/:id' => 'widgets#show'
#   match '/stream_events' => 'activity_stream_events#index', :as => :stream_events
#   resource :admin do
#     collection do
#       match :clear_lock
#       post :create_user
#       get :stats_summary
#       get :environment
#       post :update_user
#       get :no_photos
#       get :metasearch
#       get :about_us
#       get :marketing_messages
#       match :stats_by_date
#       match :welcome_note
#       get :user_setup
#       get :current_awards
#       get :profiles_summary
#       match :welcome_email
#       get :shady_admin
#       get :manage_users
#       get :awards_archive
#       get :lists_summary
#       get :reset_welcome_email
#       match :shady_history
#       get :auto_complete_for_welcome_note
#       get :system_announcement
#       get :top_10
#       match :upload_users
#       get :home_admin
#       get :add_user
#       get :terms_and_conditions
#       get :pending_users
#     end
#     member do
#       post :modify_user
#     end
#   end
# 
#   namespace :site_admin do
#     resources :site_question_categories do
#       collection do
#         post :reorder
#         get :edit_order
#       end
#     end
#     resources :site_profile_fields do
#       collection do
#         post :update_biz_card
#         get :edit_profile_page
#         post :update_profile_page
#         get :edit_biz_card
#       end
#     end
#     resources :site_profile_question_sections do
#       collection do
#         post :reorder
#         get :edit_order
#       end
#       member do
#         get :edit_questions_order
#         post :reorder_questions
#       end
#     end
#     resources :site_profile_questions
#     resources :site_registration_fields do
#       collection do
#         post :reorder
#         get :edit_order
#       end
#     end
#   end
# 
#   match 'custom_reports/:action' => 'custom_reports#(?i-mx:usage|data_dump)'
#   resources :custom_reports do
#     collection do
#       post :create_preview
#       get :form_details
#     end
#   end
# 
#   match '/reports' => 'reports#index'
#   resources :site_admin do
#     collection do
#       get :question_categories
#       get :general
#       get :edit_favicon
#       post :publish_general
#       put :update_favicon
#       get :publish
#       get :profile_basic
#       get :edit_logo
#       get :profile_advanced
#       put :update_logo
#     end
#   end
# 
#   resources :mass_mail do
#     collection do
#       get :success
#     end
#   end
# 
#   resources :users do
#     collection do
#       get :never_logged_in
#       post :resend_welcome_bulk
#     end
#     member do
#       post :resend_welcome
#       post :clear_lock
#       get :registration_details
#       post :activate
#     end
#   end
# 
#   resources :sponsor_accounts do
#     resources :sponsor_members do    
#       member do
#         post :add_group
#         post :remove_group
#       end
#     end
# 
#     resources :sponsor_groups do
#       member do
#         post :transfer_ownership
#         post :add_sponsor
#         post :remove_sponsor
#         get :delete
#       end
#     end
#   end
# 
#   resources :sponsor_members do
#     member do
#       match :reset_password
#       match :unlock
#     end
#   end
# 
#   resources :answers do
#     resources :abuse do
#       collection do
#         get :abuse_popup
#       end
#     end
#   end
# 
#   resources :api do
#     collection do
#       get :photos
#       get :groups
#       get :profiles
#       get :request_key
#       get :whoami
#       get :widgets
#       get :public_key
#       post :sync_users
#       get :notes
#       get :answers
#       get :questions
#       get :sync_users_status
#       get :stream
#       get :blog_posts
#     end
#   end
# 
#   resource :api_key
# 
#   resources :audit do
#     collection do
#       match :query
#     end
#   end
# 
#   resources :blog_posts do  
#     resources :abuse do
#       collection do
#         get :abuse_popup
#       end
#     end
#   end
# 
#   resources :videos do
#     collection do
#       get :encoding_info
#     end
#     member do
#       get :admin
#       get :remote
#       get :remote_image
#     end
#   end
# 
#   resources :bookmarks do
#     collection do
#       match :create
#     end
#     member do
#       match :remove
#     end
#   end
# 
#   resources :comments do
#     resources :abuse do
#       collection do
#         get :abuse_popup
#       end
#     end
#   end
# 
#   resources :explorations do
#     collection do
#       get :people_terms_explore
#       get :smarts_query
#       get :videos
#       get :smarts
#       get :groups
#       get :people_query
#       get :people
#       get :question_referrers
#       get :blogs
#       get :profiles_referred_to_question
#       get :travels
#       get :questions
#       get :groups_referred_to_question
#       get :statuses
#     end
#   end
# 
#   resources :travels do  
#     member do
#       get :itinerary
#       match :toggle_privacy
#     end
#   end
# 
#   resources :statuses
#   resources :statuses
#   resource :feedback
#   resources :global do
#     member do
#       put :update_inline
#     end
#   end
#   
#   resources :groups do
#     resources :abuse do
#       collection do
#         get :abuse_popup
#       end
#     end
#   
#     resources :photos
#     resource :blog do
#       resources :blog_posts
#       resources :posts
#     end
#   
#     resources :group_posts
#     resource :announcement
#     resources :gallery_photos do
#       member do
#         post :new_comment
#         match :rate
#         get :delete
#       end
#     end
#   end
# 
#   resources :marketing_messages do
#     member do
#       match :toggle_activation
#     end
#   end
# 
#   resources :notes do
#     resources :abuse do
#       collection do
#         get :abuse_popup
#       end
#     end
#   end
# 
#   resources :group_posts do
#     resources :abuse do
#       collection do
#         get :abuse_popup
#       end
#     end
#   end
# 
#   resources :gallery_photos do
#     resources :abuse do
#       collection do
#         get :abuse_popup
#       end
#     end
#   end
# 
#   match '/profile/:username' => 'profiles#show'
#   match '/profile' => 'profiles#my'
#   resources :profiles do
#     collection do
#       get :hub
#       get :external
#       match :my_widget
#       post :toggle_widget
#       post :update_widget_sequence
#       get :refresh_hot_topics_widget
#       get :refresh_explore_profiles_widget
#       get :karma_popup
#       get :completion_popup
#       get :external_widget
#     end
#     
#     member do
#       match :update, :via => :put # Should be put
#       get :awards_popup
#       get :groups
#       get :watched_questions
#       get :watch_list
#       get :completion_popup
#       get :notes
#       get :questions_with_best_answers
#       get :questions_answered
#       get :questions_asked
#       get :matched_questions
#       get :more_matched_questions
#       get :questions_answers
#     end
#     
#     resources :abuse do
#       collection do
#         get :abuse_popup
#       end
#     end
# 
#     resources :photos do
#       member do
#         match :select
#         put :make_primary
#       end
#     end
# 
#     resource :blog do
#       resources :blog_posts
#       resources :posts
#     end
# 
#     resources :watches do
#       collection do
#         get :groups
#         get :profiles
#         get :feed
#         match :create
#       end
#     end
# 
#     resources :travels do
#       member do
#         get :itinerary
#       end
#     end
#   end
# 
#   resources :replies do
#     resources :abuse do
#       collection do
#         get :abuse_popup
#       end
#     end
#   end
# 
#   resources :retrievals do
#     collection do
#       post :admin_reset
#     end
#     member do
#       match :password_reset
#     end
#   end
# 
#   resources :questions do
#     resources :abuse do
#       collection do
#         get :abuse_popup
#       end
#     end
# 
#     resources :answers do
#       resources :vote do
#         collection do
#           post :helpful
#           post :not_helpful
#         end
#       end
#     end
#   end
# 
#   resources :question_referrals do
#     collection do
#       get :auto_complete_for_referral
#       get :new
#     end
#   end
# 
#   resources :group_invitations do
#     collection do
#       get :auto_complete_for_group_invitation_profile
#       get :invitation_popup
#       post :validate_invitation_profiles
#     end
#     member do
#       post :invitation_request
#       post :decline_invitation_request
#       post :accept_invitation_request
#       post :resend
#       post :rescind
#     end
#   end
# 
#   resources :system_announcements do
#     collection do
#       post :create
#     end
#   end
# 
#   resources :terms_and_conditions do
#     collection do
#       post :create
#     end
#   end
# 
#   resources :default_widgets do
#     collection do
#       post :create
#     end
#   end
# 
#   resources :awards do
#     member do
#       get :recipients
#       put :update
#       post :toggle_visibility
#       post :copy
#       post :update_image
#       get :assign_award
#     end
#   end
# 
#   resources :profile_awards do
#     collection do
#       get :auto_complete_for_profile_awards
#     end
#     member do
#       delete :destroy
#       post :make_default
#       post :toggle_visibility
#     end
#   end
#   
#   match '/' => 'profiles#hub', :as => :home
# end
# 
# #####
# 
# # Documentation
# # IterEngineRails3::Application.routes.draw do
#   # The priority is based upon order of creation:
#   # first created -> highest priority.
# 
#   # Sample of regular route:
#   #   match 'products/:id' => 'catalog#view'
#   # Keep in mind you can assign values other than :controller and :action
# 
#   # Sample of named route:
#   #   match 'products/:id/purchase' => 'catalog#purchase', :as => :purchase
#   # This route can be invoked with purchase_url(:id => product.id)
# 
#   # Sample resource route (maps HTTP verbs to controller actions automatically):
#   #   resources :products
# 
#   # Sample resource route with options:
#   #   resources :products do
#   #     member do
#   #       get 'short'
#   #       post 'toggle'
#   #     end
#   #
#   #     collection do
#   #       get 'sold'
#   #     end
#   #   end
# 
#   # Sample resource route with sub-resources:
#   #   resources :products do
#   #     resources :comments, :sales
#   #     resource :seller
#   #   end
# 
#   # Sample resource route with more complex sub-resources
#   #   resources :products do
#   #     resources :comments
#   #     resources :sales do
#   #       get 'recent', :on => :collection
#   #     end
#   #   end
# 
#   # Sample resource route within a namespace:
#   #   namespace :admin do
#   #     # Directs /admin/products/* to Admin::ProductsController
#   #     # (app/controllers/admin/products_controller.rb)
#   #     resources :products
#   #   end
# 
#   # You can have the root of your site routed with "root"
#   # just remember to delete public/index.html.
#   # root :to => "welcome#index"
# 
#   # See how all your routes lay out with "rake routes"
# 
#   # This is a legacy wild controller route that's not recommended for RESTful applications.
#   # Note: This route will make all actions in every controller accessible via GET requests.
#   # match ':controller(/:action(/:id(.:format)))'
# # end
