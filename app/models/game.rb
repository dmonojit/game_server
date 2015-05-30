class Game < ActiveRecord::Base
  MIN_PLAYERS = 2
  MAX_PLAYERS = 5

  WAITING = 'waiting'
  IN_PLAY = 'in_play'
  COMPLETED = 'completed'

  PASS = 1
  FAIL = 0

  VALID_STATES = [WAITING, IN_PLAY, COMPLETED]

  belongs_to :admin, :class_name => 'Player'
  has_one :grid
  has_many :players
  has_one :next_player, :class_name => 'Player'
  has_one :winner_player, :class_name => 'Player'

  class << self
    def create_game(admin_nick)
      game = Game.create!(:state => WAITING)
      admin_nick ||= random_admin_nick(game.id)
      admin = Player.create_player(admin_nick, game.id)
      game.update_attributes!(:admin_id => admin.id, :external_game_id => external_game_id(game.id),
                              :next_player_id => admin.id)
      Grid.create_grid(game.id)
      game
    end

    def external_game_id(game_id)
      "GAME-#{game_id}"
    end

    def random_admin_nick(game_id)
      "ADMIN-GAME-#{game_id}"
    end
  end

  def join(player_nick)
    return [false, nil] unless self.can_join?
    player_nick ||= random_player_nick
    player = Player.create_player(player_nick, self.id)
    update_last_player(player.id)
    [true, player]
  end

  def start(player_id)
    flag, message = can_start?(player_id)
    return [flag, message, nil] unless flag
    mark_as_started
    [true, 'Game successfully started', self.grid]
  end

  def play(player_id, word)
    flag, message = can_play?(player_id)
    return [flag, message, 0] unless flag
    player = Player.find_by_external_player_id(player_id)
    update_next_player(player.next_player_id)
    score = word.blank? ?  play_pass : play_with_word(player, word)
    [true, 'Game Played', score]
  end

  def play_pass
    FAIL
  end

  def play_with_word(player, word)
    remaining_valid_grids = self.grid.valid_grids.not_found
    valid_word = remaining_valid_grids.collect(&:word).include?(word)
    if valid_word
      chosen_valid_grid = remaining_valid_grids.detect{ |grid| grid.word.eql?(word) }
      chosen_valid_grid.update_found_by(player.id)
      mark_as_completed if self.grid.valid_grids.not_found.blank?
      player.update_score(PASS)
      PASS
    else
      FAIL
    end
  end

  def can_join?
    self.players.size < MAX_PLAYERS && self.waiting?
  end

  def can_start?(player_id)
    player = Player.find_by_external_player_id(player_id)
    return [false, "Invalid Player : #{player_id}"] if player.nil?
    return [false, "Game : #{self.external_game_id} is already #{self.state}"] unless self.waiting?
    return [false, "Player : #{player_id} is not admin"] unless self.admin_id == player.id
    no_of_players = self.players.size
    return [false, "Only #{no_of_players} joined, minimum required : #{MIN_PLAYERS}"] if no_of_players < MIN_PLAYERS
    [true, nil]
  end

  def can_see_info?(player_id)
    return false if self.players.where(:external_player_id => player_id).blank?
    true
  end

  def can_play?(player_id)
    return [false, "Game : #{self.external_game_id} is already #{self.state}"] unless self.in_play?
    player = Player.find_by_external_player_id(player_id)
    return [false, "Invalid Player : #{player_id}"] if player.nil?
    return [false, "Player : #{player_id} is not playing Game : #{self.external_game_id}"] unless player.game_id == self.id
    return [false, "This is not the turn of Player : #{player_id}"] unless self.next_player_id == player.id
    [true, nil]
  end

  def players
    Player.where(:game_id => self.id)
  end

  def waiting?
    self.state == WAITING
  end

  def in_play?
    self.state == IN_PLAY
  end

  def info
    {
        :game_status => self.state,
        :current_player => self.next_player.nick,
        :words_done => self.grid.valid_grids.found.collect(&:word),
        :scores => self.players.inject({}) do |hash, player|
          hash.merge!(player.nick => player.score)
        end,
        :winner => self.winner_player,
        :grid => self.grid_info
    }
  end

  def grid_info
    col = self.grid.no_of_columns
    self.grid.blocks.sort_by{ |block| (block.row * col) + block.column }.collect(&:letter).each_slice(col).to_a
  end

  private

  def random_player_nick
    "PLAYER-GAME-#{self.id}"
  end

  def mark_as_started
    update_last_player(self.admin_id)
    self.update_attributes!(:state => IN_PLAY)
  end

  def mark_as_completed
    winner = self.game.players.sort_by(&:score).last
    update_winner_player(winner.id)
    self.update_attributes!(:status => COMPLETED)
  end

  def update_next_player(player_id)
    self.update_attributes!(:next_player_id => player_id)
  end

  def update_winner_player(player_id)
    self.update_attributes!(:winner_player_id => player_id)
  end

  def update_last_player(player_id)
    last_player = self.players.last_player.where('"players".id != ?', player_id).first
    last_player.update_attributes!(:next_player_id => player_id)
  end
end
