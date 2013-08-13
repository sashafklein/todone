Todone::Application.routes.draw do
  
  resources :landing, only: [:splash]
  
  resources :users do
    resources :items
  end

  resources :items do 
    post :archive, on: :member
  end

  root to: 'landing#splash'

end
