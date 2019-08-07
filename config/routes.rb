Rails.application.routes.draw do
  devise_for :users, controllers: { registrations: 'users/registrations' }
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  root to: 'concerts#index'
  resources :concerts
  post 'search_concert' => 'search_results#search_concert'
end
