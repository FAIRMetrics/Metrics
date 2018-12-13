Rails.application.routes.draw do
  get 'static_pages/home'

  get 'static_pages/help'

  get 'static_pages/about'

  resources :evaluations
  resources :collections   # the "resources" command auto-creates the default routes, including POST going to #create
  resources :metrics

   
  root 'static_pages#show'
  get '/about', to: 'static_pages#show'
  

  get 'collect_metrics/:id', to: 'collections#collect_metrics'
  post 'collect_metrics/:id', to: 'collections#register_metrics'
 
  get 'evaluations/:id/template', to: 'evaluations#template', as: 'template'
  post 'evaluations/:id/execute', to: 'evaluations#execute_analysis'  # accepts FORM data, or JSON
  post 'evaluations/:id/result', to: 'evaluations#execute_analysis_json', as: 'result'  # I think this is more REST-like...??  posting to Result to update the state of Result?  
  get 'evaluations/:id/result', to: 'evaluations#result'
  post 'evaluations/:id/result', to: 'evaluations#result'
  get 'evaluations/:id/error', to: 'evaluations#error'
  
  
  # API methods
  namespace :v1, defaults: {format: 'json'} do
    scope '/users' do
      post "register" => 'users#register'
      post "auth/login", to: 'users#login'
      get "test", to: 'users#test'  # a way to test authentication without payload - are you still logged-in?
    end
  end
  
  
  
end
