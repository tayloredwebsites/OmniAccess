Rails.application.routes.draw do

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  get 'home/index'
  root to: 'home#index'

  devise_for :users

  resources :accesses, only: [:index, :show, :create, :destroy]

  match 'auth/:provider/callback', :to => 'accesses#create', via: [:get, :post]
  match 'auth/failure', :to => 'accesses#create', via: [:get, :post]

  get 'remote_files/:access_id' => 'remote_files#index', as: 'remote_files'

  devise_scope :user do
    get '/users/sign_out' => 'devise/sessions#destroy'
  end



end
