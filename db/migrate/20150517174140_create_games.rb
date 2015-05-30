class CreateGames < ActiveRecord::Migration
  def change
    create_table :games do |t|
      t.string :external_game_id
      t.string :state
      t.integer :admin_id
      t.integer :next_player_id
      t.integer :winner_player_id
      t.timestamps
    end
  end
end
