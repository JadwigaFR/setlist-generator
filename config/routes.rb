Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  root to: 'concerts#index'
  post 'import_google_playlist', to: 'playlists#import_google_playlist'

  resources :concerts, shallow: true do
    post 'create_spotify_playlist', to: 'playlists#create_spotify_playlist'
  end

  resources :playlists, shallow: true
    post 'extract_playlists', to: 'playlists#extract_playlists'


  post 'find_setlist', to: 'setlists#find_setlist'
  get '/auth/spotify/callback', to: 'users#spotify'
end
