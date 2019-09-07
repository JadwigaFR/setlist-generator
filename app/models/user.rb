class User < ApplicationRecord
  def spotify_request
  #   url = "https://accounts.spotify.com/authorize"
  #   query_params = {
  #       client_id: Rails.application.credentials[Rails.env.to_sym][:spotify][:client_id],
  #       response_type: 'code',
  #       redirect_uri: 'http://localhost:3000/api/v1/user',
  #       scope: "users-library-read playlist-read-collaborative playlist-modify-private users-modify-playback-state users-read-private users-top-read playlist-modify-public",
  #       show_dialog: true
  #   }
  #   redirect_to "#{url}?#{query_params.to_query}"
  end

  def self.from_omniauth(auth)
    where(auth.slice("provider", "uid")).first || create_from_omniauth(auth)
    raise
  end

  # def self.create_from_omniauth(auth)
  #   create! do |users|
  #     users.provider = auth["provider"]
  #     users.uid = auth["uid"]
  #     users.name = auth["info"]["nickname"]
  #   end
  # end
end
