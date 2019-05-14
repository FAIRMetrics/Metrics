Rails.application.routes.draw do

  
  root 'static_pages#home'
  
  scope "/FAIR_Evaluator" do 
  
    get 'static_pages/home'
  
    get 'static_pages/help'
  
    get 'static_pages/about'
  
    resources :evaluations
    resources :collections   # the "resources" command auto-creates the default routes, including POST going to #create
    resources :metrics
  
     
    root 'static_pages#home'
    get '/about', to: 'static_pages#home'
    get '/interface', to: 'static_pages#interface'
    get '/terms', to: 'static_pages#tos'
    get '/license', to: 'static_pages#license'
    
    
    
    post 'collections/new', to: 'collections#create'
    post 'collections', to: 'collections#create'
    post 'collections/:id/deprecate', to: 'collections#deprecate'
    get 'collections/:id/deprecate', to: 'collections#deprecate'
    post 'metrics/:id/deprecate', to: 'metrics#deprecate'
    get 'metrics/:id/deprecate', to: 'metrics#deprecate'
    get 'metrics/:id/refresh', to: 'metrics#refresh'
    
   
    #get 'collections/:id/evaluation', to: 'evaluations#template', as: 'template'
    post 'collections/:id/evaluate', to: 'evaluations#execute_analysis', as: 'executeevaluation' # collections/7/evaluate
    get 'collections/:id/evaluate/template', to: 'evaluations#template', as: 'evaluationtemplate'  # collections/7/evaluate
    
    post 'evaluations/:id/result', to: 'evaluations#result', as: 'result'
    get 'evaluations/:id/result', to: 'evaluations#result', as: 'getresult'
    #post 'evaluations/:id/result', to: 'evaluations#result'
    #get 'evaluations/:id/error', to: 'evaluations#error'
    
    
    get 'searches/new', to: 'searches#new'
    get 'searches', to: 'searches#new'
    post 'searches/new', to: 'searches#new'
    post 'searches', to: 'searches#new'
    post 'searches/:id', to: 'searches#execute'
    get 'searches/:id', to: 'searches#show'
    
    get 'schema', to: 'static_pages#schema'
    get 'schema.json', to: 'static_pages#schema'
    
    # CRON JOBS
    get 'crons/clearcache', to: 'crons#clearcache'
    
    
    # API methods
    namespace :v1, defaults: {format: 'json'} do
      scope '/users' do
        post "register" => 'users#register'
        post "auth/login", to: 'users#login'
        get "test", to: 'users#test'  # a way to test authentication without payload - are you still logged-in?
      end
    end
  
  end
  
  
end
