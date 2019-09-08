class PlaylistsController < ApplicationController
  def create_spotify_playlist
    spotify_user = RSpotify::User.new(session[:spotify_user])
    concert = Concert.find(params[:concert_id])
    spotify_track_ids = concert.setlists.sort_by(&:index).map(&:song).pluck(:spotify_id).reject(&:blank?)
    spotify_tracks = []
    spotify_track_ids.each do |track_id|
      spotify_tracks << RSpotify::Track.find(track_id)
    end
    spotify_playlist = spotify_user.create_playlist!(concert.name)
    spotify_playlist.add_tracks!(spotify_tracks)
    external_url = spotify_playlist.external_urls['spotify']
    redirect_to concert_path(session[:concert_id], external_url: external_url)
  end

  def import_playlist
    raise
  end
end
