Rails.application.routes.draw do
  get 'static_pages/home'

  get 'static_pages/help'

  get 'static_pages/about'

  resources :evaluations
  resources :collections   # the "resources" command auto-creates the default routes, including POST going to #create
  resources :metrics
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

   
  root 'static_pages#show'
  get '/about', to: 'static_pages#show'
  
    
  get 'metric', to: 'metrics#index'
  get 'metric/new', to: 'metrics#new'
  

  get 'collect_metrics/:id', to: 'collections#collect_metrics'
  post 'collect_metrics/:id', to: 'collections#register_metrics'
 
  get 'evaluation', to: 'evaluations#start_evaluation'
  
end
