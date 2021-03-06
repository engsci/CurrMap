Currmap::Application.routes.draw do |map|

  # USERS

  devise_for :users
  resources :users
  match 'unauthorized' => "pages#unauthorized"

  # FILES
  
  resources :documents
  
  # RESOURCES
  
  resources :resources
  resources :textbooks, :controller => 'resources' #reqd for formtastic

  # COLLECTIONS

  resources :collections


  # TERMS

  match 'terms/search' => 'terms#search'
  resources :terms

  # COURSES and INSTANCES

  resources :courses do
    resources :instances, :controller => 'course_instances', :except => ['index'] do
      member do
        get 'activities'
        get 'resources'
        get 'editpreview'
      end
    end
  end

  resources :course_instances, :only => ['index']

  # PEOPLE

  resources :people, :only => [:destroy]
  resources :instructors, :controller => 'people'
  #resources :authors, :controller => 'people'


  # PAGES

  match 'search' => 'pages#search'
  match 'about' => 'pages#about'
  match 'contact' => 'pages#contact'
  match 'help' => 'pages#help'

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
  #       get :short
  #       post :toggle
  #     end
  #
  #     collection do
  #       get :sold
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
  #       get :recent, :on => :collection
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

  root :to => "pages#index"

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id(.:format)))'
end
