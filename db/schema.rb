# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20150525154218) do

  create_table "blocks", :force => true do |t|
    t.integer  "row"
    t.integer  "column"
    t.string   "letter"
    t.integer  "grid_id"
    t.integer  "valid_grid_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "games", :force => true do |t|
    t.string   "external_game_id"
    t.string   "state"
    t.integer  "admin_id"
    t.integer  "next_player_id"
    t.integer  "winner_player_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "grids", :force => true do |t|
    t.integer  "game_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "players", :force => true do |t|
    t.string   "external_player_id"
    t.string   "nick"
    t.integer  "game_id"
    t.integer  "next_player_id"
    t.integer  "score",              :default => 0
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "valid_grids", :force => true do |t|
    t.string   "direction"
    t.integer  "found_by_player_id"
    t.integer  "grid_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
