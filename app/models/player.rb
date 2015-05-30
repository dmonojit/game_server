class Player < ActiveRecord::Base

  belongs_to :game

  scope :last_player, where(:next_player_id => nil)

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

  def next_player
    return nil if self.next_player_id.nil?
    Player.find(self.next_player_id)
  end

  def update_score(new_score)
    score = self.score
    self.update_attributes!(:score => score + new_score)
  end
end
