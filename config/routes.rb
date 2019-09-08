Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  root to: 'concerts#index'
  resources :concerts, shallow: true do
    post 'create_spotify_playlist', to: 'playlists#create_spotify_playlist'
  end
  post 'find_setlist', to: 'setlists#find_setlist'
  get '/auth/spotify/callback', to: 'users#spotify'
end
