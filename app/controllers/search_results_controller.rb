require 'httparty'
require 'rspotify'
RSpotify::authenticate('71e77c5f36c14c3ba1432a31f40586f8', 'd50b3ee88cc645e0a355b39e46760e8b')

class SearchResultsController < ApplicationController
  def search_concert
    concert_id = search_params[:url].split('-').last.split('.').first
    concert = Concert.find_by(setlistfm_id: concert_id)
    if concert.present?
      redirect_to concert_path(concert)
      # Add an alert to say that the concert is already present in our database.
    else
      json = get_request_for_url("#{ENV['SETLIST_FM_URL']}setlist/#{concert_id}")

      artist_name = json['artist']['name']
      artist = Artist.find_by(name: artist_name)
      import_spotify_artist(artist_name) unless artist.present?


    end
    concert = Concert.create(date: DateTime.parse(json['eventDate']))
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

  private

  def import_spotify_artist(artist_name)
    RSpotify::Artist.search(artist_name)
    # TODO extract artist details from spotify json
    raise
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
