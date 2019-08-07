class Song < ApplicationRecord
  belongs_to :album
  delegate [:artist, :date], to: :album

  def self.new_from_spotify_track(spotify_track)
    spotify_artist = spotify_track.artists[0]
    artist = Artist.find_or_create_by(spotify_id: spotify_artist.id)
    artist.update(name: spotify_artist.name)

    spotify_album = spotify_track.album
    album = Album.find_or_create_by(spotify_id: spotify_album.id)
    album.update(name: spotify_album.name, artist: spotify_album.artist, date: spotify_album.date)

    Song.find_or_create_by(
        spotify_id: spotify_track.id,
        name: spotify_track.name,
        album_id: album.id
    )
  end
end
