class CreateValidGrids < ActiveRecord::Migration
  def change
    create_table :valid_grids do |t|
      t.string :direction
      t.integer :found_by_player_id
      t.integer :grid_id
      t.timestamps
    end
  end
end
