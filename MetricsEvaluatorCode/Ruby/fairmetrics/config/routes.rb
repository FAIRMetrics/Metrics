Rails.application.routes.draw do
  resources :evaluations
  resources :collections   # the "resources" command auto-creates the default routes, including POST going to #create
  resources :metrics
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

   
  root 'static_pages#about'
  get '/about', to: 'static_pages#about'
  
    
  get 'metric', to: 'metrics#index'
  get 'metric/new', to: 'metrics#new'
  

  get 'collect_metrics/:id', to: 'collections#collect_metrics'
  post 'collect_metrics/:id', to: 'collections#register_metrics'
 
  get 'evaluation', to: 'evaluations#start_evaluation'
  
end
