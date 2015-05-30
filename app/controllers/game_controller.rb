class GameController < ApplicationController
  def new
  end

  def create
    nick = params[:nick]
    response = ActiveRecord::Base.transaction do
      game = Game.create_game(nick)
      {
          :game_id => game.external_game_id,
          :player_id => game.admin.external_player_id,
          :nick => game.admin.nick
      }
    end
    render :json => response
  end

  def join
    nick = params[:nick]
    game_id = params[:game_id]
    response = ActiveRecord::Base.transaction do
      game = Game.find_by_external_game_id(game_id)
      registered = false
      player_id = nil
      registered, player = game.join(nick) unless game.nil?
      player_id, nick = player.external_player_id, player.nick unless player.nil?
      {
          :registered => registered,
          :player_id => player_id,
          :nick => nick
      }
    end
    render :json => response
  end

  def start
    player_id = params[:user_id]
    game_id = params[:game_id]
    response = ActiveRecord::Base.transaction do
      game = Game.find_by_external_game_id(game_id)
      success = false
      message = "Invalid Game : #{game_id}"
      grid = nil
      success, message, grid = game.start(player_id) unless game.nil?
      {
          :success => success,
          :message => message,
          :grid => grid
      }
    end
    render :json => response
  end

  def info
    player_id = params[:user_id]
    game_id = params[:game_id]
    response = ActiveRecord::Base.transaction do
      game = Game.find_by_external_game_id(game_id)
      success = false
      message = "Invalid Game : #{game_id}"
      game_info = {}
      success, message, game_info = [true, "Game Info", game.info] unless game.nil? || !game.can_see_info?(player_id)
      {
          :success => success,
          :message => message,
      }.merge(game_info)
    end
    render :json => response
  end

  def play
    player_id = params[:user_id]
    game_id = params[:game_id]
    word = params[:word]
    response = ActiveRecord::Base.transaction do
      game = Game.find_by_external_game_id(game_id)
      success = false
      message = "Invalid Game : #{game_id}"
      score = 0
      success, message, score = game.play(player_id, word) unless game.nil?
      {
          :success => success,
          :message => message,
          :score => score
      }
    end
    render :json => response
  end
end