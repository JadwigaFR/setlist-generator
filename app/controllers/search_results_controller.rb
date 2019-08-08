require 'httparty'
require 'rspotify'
RSpotify::authenticate(ENV['SPOTIFY_CLIENT'], ENV['SPOTIFY_KEY'])

class SearchResultsController < ApplicationController
  def search_concert
    concert_id = extract_setlist_id(search_params[:url]).split('-').last.split('.').first
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

      concert = Concert.create(date: DateTime.parse(json['eventDate']), artist_id: artist.id, venue_id: '')
      venue = json['venue']
      tour = json['tour']
      setlist = json['sets']['set'][0]['song']
      index = 0
      setlist.each do |song|
        next if song['name'].blank?
        index += 1
        song_name = song['name']
        import_song(song_name, artist_name)
        # Check if song already if in database.
        # if true, create a setlist entry with the index
        # if false call the create song function to create the song
        raise
      end

    end



  end

  private

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

  def create_venue(venue_json)
    venue_json
    raise
  end

  def extract_setlist_id(url)

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
