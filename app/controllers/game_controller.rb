class GameController < ApplicationController
  def new

  end

  def create
    nick = params[:nick]
    response = nil
    ActiveRecord::Base.transaction do
      game = Game.create_game(nick)
      response = {
          :game_id => game.external_game_id,
          :player_id => game.admin.external_player_id,
          :nick => game.admin.nick
      }
    end
    render :json => response
  end
end