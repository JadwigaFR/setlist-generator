class AddTourToConcert < ActiveRecord::Migration[5.2]
  def change
    add_column :concerts, :tour, :string
  end
end
