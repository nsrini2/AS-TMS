ActionController::Routing::Routes.draw do |map|
  # The priority is based upon order of creation: first created -> highest priority.
  map.connect '/join', :controller => 'profiles', :action => 'hub'
  map.search '/search', :controller => 'search', :action => 'index'
  
  map.new_note '/notes/new', :controller => 'notes', :action => 'new'
  map.autocomplete_for_message_note '/messages/autocomplete', :controller => 'notes', :action => 'autocomplete_for_message'
  
  map.news '/news', :controller => 'news', :action => 'index'
  
  # Refer a friend campaign
  map.connect '/refer_a_friend', :controller => 'public_content', :action => 'refer_a_friend'
  map.connect '/refer-a-friend', :controller => 'public_content', :action => 'refer_a_friend'
  map.connect '/referafriend', :controller => 'public_content', :action => 'refer_a_friend'
  
  map.connect '/channels', :controller => 'display', :action => 'channels'
  
  # map.connect '/companies/create_question', :controller => 'companies', :action => 'create_question', :conditions => {:method => :post }
  # map.resources :companies
  map.namespace(:companies) do |companies|
    companies.connect '/hub/:id', :controller => 'hub', :action => 'show', :conditions => {:method => :get }
    companies.connect '/hub/create_question', :controller => 'hub', :action => 'create_question', :conditions => {:method => :post }
    companies.resources :questions do |question|
      question.connect 'update', :controller => 'questions', :action => 'update', :conditions => {:method => :post }
      question.resources :answers do |answer|
        answer.resource :vote, :controller => :votes, :collection => { :helpful => :post, :not_helpful => :post }
      end  
    end
    # companies.resources :groups
    companies.connect '/members/:id', :controller => 'members', :action => 'index'
  end


  # Sample of regular route:
  #   map.connect 'products/:id', :controller => 'catalog', :action => 'view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   map.purchase 'products/:id/purchase', :controller => 'catalog', :action => 'purchase'
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   map.resources :products

  # Sample resource route with options:
  #   map.resources :products, :member => { :short => :get, :toggle => :post }, :collection => { :sold => :get }

  # Sample resource route with sub-resources:
  #   map.resources :products, :has_many => [ :comments, :sales ], :has_one => :seller
  
  # Sample resource route with more complex sub-resources
  #   map.resources :products do |products|
  #     products.resources :comments
  #     products.resources :sales, :collection => { :recent => :get }
  #   end

  # Sample resource route within a namespace:
  #   map.namespace :admin do |admin|
  #     # Directs /admin/products/* to Admin::ProductsController (app/controllers/admin/products_controller.rb)
  #     admin.resources :products
  #   end

  # You can have the root of your site routed with map.root -- just remember to delete public/index.html.
  # map.root :controller => "welcome"

  # See how all your routes lay out with "rake routes"

  # Install the default routes as the lowest priority.
  # Note: These default routes make all actions in every controller accessible via GET requests. You should
  # consider removing or commenting them out if you're using named routes and resources.
  map.connect ':controller/:action/:id'
  map.connect ':controller/:action/:id.:format'
end
