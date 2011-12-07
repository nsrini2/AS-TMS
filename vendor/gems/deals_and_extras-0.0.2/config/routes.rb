Rails::Application.routes.draw do
  
  devise_for :supplier_users
  
  # map.user_root '/users', :controller => 'users' # creates user_root_path

  # The priority is based upon order of creation:
  # first created -> highest priority.

  # Sample of regular route:
  #   match 'products/:id' => 'catalog#view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   match 'products/:id/purchase' => 'catalog#purchase', :as => :purchase
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Sample resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Sample resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Sample resource route with more complex sub-resources
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', :on => :collection
  #     end
  #   end

  # Sample resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end

  scope '/deals_and_extras' do

    match '/admin(/index)', :to => 'Admin::Dashboard#index', :as => 'dashboard'
    namespace :admin do
      resources :offers do
        collection do
          post 'mass_update'
        end
      end
      resources :offer_types
      resources :supplier_users
      resources :locations do
        member do
          post :update_latlon
          get :update_latlon
        end
      end
      resources :location_types
      resources :supplier_types
      resources :state_provinces
      resources :countries
      resources :suppliers
    end
  
  end


  # scope '/deals_and_extras' do
    match "/reports/prepare/*p", :to => "reports#prepare"

    resource :reports do
      get :favorites
      get :prepare
    end
  # end
  
  scope '/deals_and_extras' do
    namespace :suppliers do
      resources :offers
    end
    resource :suppliers
  end


  match '/navigations/page', :to => 'navigations#page', :as => 'page_navigation'

  resources :offers
  resources :filters
  resources :sorts
  resources :navigations
  resources :users

  # match "/maps/*p", :to => "maps#index"
  match "/maps", :to => "maps#index"
  

  resources :offers do
    member do
      get :book
    end
    resources :reviews do
      member do
        get :up
        get :down
      end
    end
  end
  
  # resources :favorites
  
  match '/deals_and_extras', :to => 'root#index'
  
  # You can have the root of your site routed with "root"
  # just remember to delete public/index.html.
  # root :to => "root#index"

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id(.:format)))'
end
