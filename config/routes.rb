Todone::Application.routes.draw do
  
  resources :landing, only: [:splash]
  
  resources :users do
    resources :items
  end

  resources :items do 
    post :toggle, on: :member
  end

  resources :sessions, only: [:new, :create, :destroy]
    match '/signup',  to: 'users#new',            via: 'get'
    match '/signin',  to: 'sessions#new',         via: 'get'
    match '/signout', to: 'sessions#destroy',     via: 'delete'

  post :receive, to: 'incoming_emails#receive'

  root to: 'landing#splash'

end
