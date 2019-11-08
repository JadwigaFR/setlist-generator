class PlaylistsController < ApplicationController
  require 'zip'

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

  def import_google_playlist
    raise
    Zip::File.open(params[:file], Zip::File::CREATE) do |zip_file|
      # Handle entries one by one
      zip_file.each do |entry|
        # Extract to file/directory/symlink
        puts "Extracting #{entry.name}"
        entry.extract(dest_file)

        # Read into memory
        content = entry.get_input_stream.read
      end

      # Find specific entry
      entry = zip_file.glob('*.csv').first
      puts entry.get_input_stream.read
    end
    redirect_to select_playlists_path(@playlists)
  end

  def select_playlist
    @playlists
    raise
  end
end
