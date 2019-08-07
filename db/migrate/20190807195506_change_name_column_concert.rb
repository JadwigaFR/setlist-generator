class ChangeNameColumnConcert < ActiveRecord::Migration[5.2]
  def change
    rename_column :concerts, :setlist_fm_url, :setlistfm_id
  end
end
