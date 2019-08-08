require 'httparty'
require 'rspotify'

class SearchResultsController < ApplicationController
  before_action :connect_to_spotify

  def search_concert
    concert_id = extract_setlist_id(search_params[:url])
    concert = Concert.find_by(setlistfm_id: concert_id)

    if concert.present?
      redirect_to concert_path(concert)
      # Add an alert to say that the concert is already present in our database.
    else
      json = get_request_for_url("#{ENV['SETLIST_FM_URL']}setlist/#{concert_id}")

      artist_name = json['artist']['name']
      artist = Artist.find_by(name: artist_name)
      artist = import_spotify_artist(artist_name) unless artist.present?

      venue_hash = json['venue']
      venue = Venue.find_by(name: venue_hash['name'])
      venue = create_venue(venue_hash) unless venue.present?
      concert = Concert.create(date: DateTime.parse(json['eventDate']), artist_id: artist.id, venue_id: venue.id, tour: json['tour']['name'])
      setlist = json['sets']['set'][0]['song']
      index = 0
      setlist.each do |song|
        next if song['name'].blank?
        index += 1
        song_name = song['name']
        saved_song = Song.find_by(name: song_name, artist_id: artist.id)
        saved_song = import_song(song_name, artist_name) unless saved_song.present?
        concert.setlists.create(concert_id: concert.id, song_id: saved_song.id)
      end
    end
    raise
  end



  private

  def connect_to_spotify
    RSpotify::authenticate(ENV['SPOTIFY_ID'], ENV['SPOTIFY_SECRET'])
  end

  def import_spotify_artist(artist_name)
    artists = RSpotify::Artist.search(artist_name)

    if artists.count.eql?(1)
      spotify_artist = artists[0]
    else
      artists.each_with_index do |artist, index|
        next unless artist.name.eql?(artist_name)
        next unless artist.popularity > artists[index-1].popularity
        spotify_artist = artist
      end
    end
    Artist.create(name: spotify_artist.name, spotify_id: spotify_artist.id, genres: spotify_artist.genres, image: spotify_artist.images.first['url'])
  end

  def import_song(song_name, artist_name)
    songs = RSpotify::Track.search(song_name).reject{|song| !song.artists.map(&:name).include?(artist_name)}
    spotify_song = songs.select{|song| song.popularity.eql?(songs.map(&:popularity).max)}[0]
    spotify_song_album = spotify_song.album
    album = Album.find_or_create_by(spotify_id: spotify_song_album.id)
    Album.create(name: spotify_song_album.name, date: DateTime.parse(spotify_song_album.release_date), artist_id: Artist.find(artist_name).id, spotify_id: spotify_song_album.id) unless album.present?
    Song.create(name: song_name, album_id: album.id, spotify_id: spotify_song.id)
  end

  def create_venue(venue_json)
    venue_json
    Venue.create(name: venue_json['name'], city: venue_json['city']['name'], country: venue_json['city']['country']['name'], setlist_fm_id: extract_setlist_id(venue_json['url']))
    raise
  end

  def extract_setlist_id(url)
    url.split('-').last.split('.').first
  end

  def get_request_for_url(url)
    headers = {
        'x-api-key': ENV['SETLISTFM_API_KEY'],
        'Accept': 'application/json'
    }
    response = HTTParty.get(url, headers: headers)
    JSON.parse(response.body)
  end

  def search_params
    params.permit(:url)
  end
end
