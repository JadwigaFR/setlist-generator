class AddUrlToConcert < ActiveRecord::Migration[5.2]
  def change
    add_column(:concerts, :setlist_fm_url, :string)
  end
end
