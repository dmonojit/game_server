class CreatePlayers < ActiveRecord::Migration
  def change
    create_table :players do |t|
      t.string :external_player_id
      t.string :nick
      t.boolean :is_winner
      t.integer :game_id
      t.integer :next_player_id
      t.timestamps
    end
  end
end
