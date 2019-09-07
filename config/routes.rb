Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  root to: 'concerts#index'
  resources :concerts, shallow: true do
    post 'create_playlist', to: 'spotify#create_playlist'
  end
  post 'search_concert', to: 'search_results#search_concert'
  get '/auth/spotify/callback', to: 'users#spotify'
end
