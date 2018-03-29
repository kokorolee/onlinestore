Rails.application.routes.draw do

  root 'products#index'
  resources :products
  resources :productgroups
  resources :cart, only: [:show]
  resources :order_items, only: [:create, :update, :destroy]
  mount RailsAdmin::Engine => '/admin', as: 'rails_admin'
  devise_for :users
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
