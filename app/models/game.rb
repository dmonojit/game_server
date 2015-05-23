class Game < ActiveRecord::Base
  MIN_PLAYERS = 2
  MAX_PLAYERS = 5

  WAITING = 'waiting'
  IN_PLAY = 'in_play'
  COMPLETED = 'completed'

  VALID_STATES = [WAITING, IN_PLAY, COMPLETED]

  belongs_to :admin, :class_name => 'Player'

  class << self
    def create_game(admin_nick)
      game = Game.create!(:state => WAITING)
      admin_nick ||= random_admin_nick(game.id)
      admin = Player.create_player(admin_nick, game.id)
      game.update_attributes!(:admin_id => admin.id, :external_game_id => external_game_id(game.id),
                              :current_player_id => admin.id)
      game
    end

    def external_game_id(game_id)
      "GAME-#{game_id}"
    end

    def random_admin_nick(game_id)
      "ADMIN-GAME-#{game_id}"
    end
  end

end
