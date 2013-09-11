Todone::Application.routes.draw do
  
  resources :landing, only: [:splash]
  
  resources :users do
    resources :items
  end

  resources :items do 
    post :toggle, on: :member
  end

  post :receive, to: 'incoming_emails#receive'

  root to: 'landing#splash'

end
