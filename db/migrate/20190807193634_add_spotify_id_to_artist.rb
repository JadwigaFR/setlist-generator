class AddSpotifyIdToArtist < ActiveRecord::Migration[5.2]
  def change
    add_column(:artists, :spotify_id, :string)
    add_column(:albums, :spotify_id, :string)
  end
end
