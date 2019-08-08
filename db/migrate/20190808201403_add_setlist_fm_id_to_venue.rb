class AddSetlistFmIdToVenue < ActiveRecord::Migration[5.2]
  def change
    add_column :venues, :setlist_fm_id, :string
  end
end
