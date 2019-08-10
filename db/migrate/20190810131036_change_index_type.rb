class ChangeIndexType < ActiveRecord::Migration[5.2]
  def change
    remove_column :setlists, :index
    add_column :setlists, :index, :integer
  end
end
