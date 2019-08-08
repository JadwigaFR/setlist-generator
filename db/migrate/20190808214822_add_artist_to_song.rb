class AddArtistToSong < ActiveRecord::Migration[5.2]
  def change
    add_reference(:songs, :artist)
  end
end
