class PlaylistsController < ApplicationController
  require 'zip'
  require 'csv'
  before_action :set_user

  def index
    @playlists = @user.playlists
  end

  def extract_playlists
    user_id = @user.id

    playlists_params.each do |playlist_id|
      playlist = RSpotify::Playlist.find(user_id, playlist_id)
      CSV.open("#{Rails.root}/public/playlists/#{Time.now.strftime("%C%m%d")}_#{playlist.name}.csv", "wb", headers: true) do |csv|
        csv << ['song_name', 'artist_name']
        playlist.tracks.each do |song|
          csv << [song.name, song.artists.first.name]
        end
      end
    end
    redirect_to root_path, flash: {notice: "Find your playlists in the Public/Playlist folder!"}
  end

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
  end

  private

  def playlists_params
    params.require(:playlists)
  end

  def set_user
    @user = RSpotify::User.new(session[:spotify_user])
  end
end
