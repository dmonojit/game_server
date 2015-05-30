class CreateBlocks < ActiveRecord::Migration
  def change
    create_table :blocks do |t|
      t.integer :row
      t.integer :column
      t.string  :letter
      t.integer :grid_id
      t.integer :valid_grid_id
      t.timestamps
    end
  end
end
