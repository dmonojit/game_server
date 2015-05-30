class CreateGrids < ActiveRecord::Migration
  def change
    create_table :grids do |t|
      t.integer :game_id
      t.timestamps
    end
  end
end
