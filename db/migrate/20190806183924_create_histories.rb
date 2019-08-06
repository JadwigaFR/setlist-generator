class CreateHistories < ActiveRecord::Migration[5.2]
  def change
    create_table :histories do |t|
      t.references :concert, foreign_key: true
      t.references :user, foreign_key: true
      t.boolean :spotify
      t.boolean :favorite
      t.boolean :participation

      t.timestamps
    end
  end
end
