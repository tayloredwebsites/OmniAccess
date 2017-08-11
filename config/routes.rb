Rails.application.routes.draw do
  get 'home/index'
  root to: 'home#index'

  devise_for :users
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  resources :accesses, only: [:index, :show, :create, :destroy]

  match 'auth/:provider/callback', :to => 'accesses#create', via: [:get, :post]
  match 'auth/failure', :to => 'accesses#create', via: [:get, :post]

end
