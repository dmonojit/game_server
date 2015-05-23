class Player < ActiveRecord::Base

  class << self
    def create_player(nick, game_id)
      player = Player.create!(:nick => nick, :game_id => game_id)
      player.update_attributes!(:external_player_id => external_player_id(player.id))
      player
    end

    def external_player_id(player_id)
      "PLAYER-#{player_id}"
    end
  end

end
