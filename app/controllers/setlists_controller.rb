class SetlistsController < ApplicationController

  def find_setlist
    @concert_id = extract_setlist_id(search_params)
    concert = Concert.find_by(setlistfm_id: @concert_id)
    if concert.present?
      redirect_to concert_path(concert), flash: { notice: "Setlist already exist" }
    else
      json = get_request_for_url("#{ENV['SETLIST_FM_URL']}setlist/#{@concert_id}")
      @concert_setlist = json.dig('sets', 'set')
      if @concert_setlist.blank?
        redirect_to new_concert_path, flash: {notice: "We couldn't find a setlist" }
      else
        create_setlist(json)
        redirect_to concert_path(@concert), flash: { notice: "Setlist succesfully imported" }
      end
    end
  end

  def create_setlist(json)
    # Artist
    artist_name = json.dig('artist', 'name')
    artist = Artist.find_by(name: artist_name)
    artist ||= import_spotify_artist(artist_name)
    # Venue
    venue_json = json['venue']
    venue = Venue.find_by(name: venue_json  ['name'])
    venue ||= Venue.create!(name: venue_json['name'], city: venue_json.dig('city', 'name'), country: venue_json.dig('city', 'country', 'name'), setlist_fm_id: extract_setlist_id(venue_json['url']))
    # Concert
    @concert = Concert.create!(date: DateTime.parse(json['eventDate']), artist_id: artist.id, venue_id: venue.id, tour: json.dig('tour', 'name'), setlistfm_id: @concert_id)
    # Setlist
    setlist = []
    @concert_setlist.each{|set| setlist << set['song']}
    song_pool = RSpotify::Artist.find(artist.spotify_id).albums.uniq(&:name).map(&:tracks).flatten
    setlist.flatten.reject{|hash| hash['name'].blank?}.each_with_index do |song, index|
      song_name = song['name']
      saved_song = Song.find_by(name: song_name, artist_id: artist.id)
      saved_song ||= import_song(song_name, song_pool, artist)
      @concert.setlists.create!(song_id: saved_song.id, index: index += 1)
    end
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
    Artist.create!(name: spotify_artist.name, spotify_id: spotify_artist.id, genres: spotify_artist.genres, image: spotify_artist.images.first['url'])
  end

  def import_song(song_name, song_pool, artist)
    spotify_songs = song_pool.select{ |spotify_track| spotify_track.name.eql?(song_name)}
    spotify_song = spotify_songs.find{ |song| song.popularity.eql?(spotify_songs.map(&:popularity).max) }

    if spotify_song.nil?
      Song.create!(name: song_name)
    else
      spotify_song_album = spotify_song.album
      album = Album.find_or_create_by!(spotify_id: spotify_song_album.id, artist: artist)
      Album.update!(name: spotify_song_album.name, date: DateTime.parse(spotify_song_album.release_date), artist_id: artist.id) unless album.present?
      Song.create!(name: song_name, album_id: album.id, spotify_id: spotify_song.id, artist_id: artist.id)
    end
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

  private

  def search_params
    params.require(:url)
  end
end
