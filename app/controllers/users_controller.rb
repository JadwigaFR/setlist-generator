class UsersController < ActionController::Base
  def spotify
    @spotify_user = RSpotify::User.new(request.env['omniauth.auth'])
    hash = @spotify_user.to_hash
    session[:spotify_user] = hash
    create_playlist
    redirect_to concert_path(session[:concert_id], external_url: @external_url)
  end

  def create_playlist
    @concert = Concert.find(session[:concert_id])
    spotify_track_ids = @concert.setlists.sort_by(&:index).map(&:song).pluck(:spotify_id)
    spotify_tracks = []
    spotify_track_ids.each do |track_id|
      spotify_tracks << RSpotify::Track.find(track_id)
    end
    @spotify_playlist = @spotify_user.create_playlist!(@concert.name)
    @spotify_playlist.add_tracks!(spotify_tracks)
    @external_url = @spotify_playlist.external_urls['spotify']
  end
end
