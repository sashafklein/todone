Todone::Application.routes.draw do
  resources :users do
    resources :items
  end
end
