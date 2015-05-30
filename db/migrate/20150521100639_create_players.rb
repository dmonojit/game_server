class CreatePlayers < ActiveRecord::Migration
  def change
    create_table :players do |t|
      t.string :external_player_id
      t.string :nick
      t.integer :game_id
      t.integer :next_player_id
      t.integer :score, :default => 0
      t.timestamps
    end
  end
end
