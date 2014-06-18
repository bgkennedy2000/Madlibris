Madlibris::Application.routes.draw do

  devise_for :users, controllers: { :omniauth_callbacks => "omniauth_callbacks" }

  resources :madlibris_games  
  root to: "home#index"
  post 'madlibris_games', to: 'madlibris_games#create_game', as: "create_madlibris_game"
  get 'madlibris_display', to: "madlibris_games#options_display", as: 'options_display'
  get 'madlibris_game_view', to: 'madlibris_games#game_view', as: "play_madlibris_game"
  post 'choose_book', to: 'madlibris_games#choose_book', as: "choose_madlibris_book"
  post 'accept_invite', to: 'madlibris_games#accept_invite', as: "accept_invitation"
  post 'reject_invite', to: 'madlibris_games#reject_invite', as: "reject_invitation"
  post 'uninvite', to: 'madlibris_games#uninvite', as: "uninvite_user"
  get 'new_first_line/:id', to: 'madlibris_games#new_line', as: "new_first_line"
  post 'write_first_line', to: 'madlibris_games#write_line', as: "write_line"
  get 'new_line_choice/:id', to: 'madlibris_games#new_line_choice', as: "new_line_choice"
  post 'make_line_choice', to: 'madlibris_games#choose_line', as: "choose_line"
  post 'send_invite', to: 'madlibris_games#send_invite', as: "send_invite"

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

  # You can have the root of your site routed with "root"
  # just remember to delete public/index.html.
  # root :to => 'welcome#index'

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id))(.:format)'
end
